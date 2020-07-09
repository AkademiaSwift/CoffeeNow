import Vapor


final class PiggyController {

    func getBalance(_ req: Request) throws -> Future<PiggyBalanceReply> {
        let sessionId = req.http.headers.firstValue(name: HTTPHeaderName("X-Session-Id")) ?? ""
        guard let uuidSessionId = UUID(sessionId) else { throw Abort(.forbidden) }
        return Session.find(uuidSessionId, on: req).unwrap(or: Abort(.forbidden)).flatMap { session in
            return session.user.get(on: req).flatMap { user in
                return Piggy.query(on: req).filter(\.userID, .equal, user.id ?? 0).all().map { piggies in
                    var lastUpdate = piggies.count > 0 ? Date(timeIntervalSinceNow: -365 * 24 * 60 * 60) : Date()
                    var balance = Decimal.zero
                    var balanceString = "PLN"
                    for piggy in piggies {
                        balance += piggy.balance
                        balanceString = piggy.currency
                        if lastUpdate < piggy.createdAt {
                            lastUpdate = piggy.createdAt
                        }
                    }
                    return PiggyBalanceReply(balance: balance, balanceCurrency: balanceString, lastUpdate: lastUpdate)
                }
            }
        }
    }
    
    func updateBalance(_ req: Request) throws -> Future<HTTPStatus> {
        let sessionId = req.http.headers.firstValue(name: HTTPHeaderName("X-Session-Id")) ?? ""
        guard let uuidSessionId = UUID(sessionId) else { throw Abort(.forbidden) }
        return Session.find(uuidSessionId, on: req).unwrap(or: Abort(.forbidden)).flatMap { session in
            return session.user.get(on: req).flatMap { user in
                return try req.content.decode(PiggyUpdateRequest.self).flatMap { content in
                    let piggy = Piggy(balance: content.balance, currency: content.balanceCurrency, userID: user.id ?? 0)
                    return piggy.save(on: req).map { _ in
                        return HTTPStatus.ok
                    }
                }
            }
        }
    }
    
}
