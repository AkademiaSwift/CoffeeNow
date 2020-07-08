import Vapor

class UserMiddleware: Middleware {
    func respond(to request: Request, chainingTo next: Responder) throws -> EventLoopFuture<Response> {
        guard request.http.headers.contains(name: "X-Session-Id") else {
            throw Abort(.forbidden)
        }
        let sessionId = request.http.headers.firstValue(name: HTTPHeaderName("X-Session-Id")) ?? ""
        guard let uuidSessionId = UUID(sessionId) else {
            throw Abort(.forbidden)
        }
        return Session.find(uuidSessionId, on: request).unwrap(or: Abort(.forbidden)).flatMap { session in
            guard Date().compare(session.expired) == ComparisonResult.orderedAscending else {
                throw Abort(.forbidden)
            }
            guard session.userID != nil else {
                throw Abort(.forbidden)
            }
            session.expired = Date(timeIntervalSinceNow: 3600)
            return session.save(on: request).flatMap { _ in
                return try next.respond(to: request)
            }
        }
    }
}
