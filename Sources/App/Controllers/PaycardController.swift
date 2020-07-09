import Vapor


final class PaycardController {

    func index(_ req: Request) throws -> Future<[PaycardListReply]> {
        let sessionId = req.http.headers.firstValue(name: HTTPHeaderName("X-Session-Id")) ?? ""
        guard let uuidSessionId = UUID(sessionId) else { throw Abort(.forbidden) }
        return Session.find(uuidSessionId, on: req).unwrap(or: Abort(.forbidden)).flatMap { session in
            return session.user.get(on: req).flatMap { user in
                return Paycard.query(on: req).filter(\.userID, .equal, user.id ?? 0).all().map { paycards in
                    var list = [PaycardListReply]()
                    for paycard in paycards {
                        list.append(PaycardListReply(id: paycard.id ?? 0, name: paycard.paycardName, number: paycard.paycardNumber, expired: paycard.expired, type: paycard.type))
                    }
                    return list
                }
            }
        }
    }
    
    func addpre(_ req: Request) throws -> PaycardAddOneReply {
        return PaycardAddOneReply(entrophy: Session.randomTransportKey(length: 64))
    }
    
    func addcom(_ req: Request) throws -> Future<HTTPStatus> {
        let sessionId = req.http.headers.firstValue(name: HTTPHeaderName("X-Session-Id")) ?? ""
        guard let uuidSessionId = UUID(sessionId) else { throw Abort(.forbidden) }
        return Session.find(uuidSessionId, on: req).unwrap(or: Abort(.forbidden)).flatMap { session in
            return session.user.get(on: req).flatMap { user in
                return try req.content.decode(PaycardAddTwoRequest.self).flatMap { content in
                    let number = "1234567890123456"
                    let paycard = Paycard(type: content.type, paycardName: content.name, paycardNumber: number, holderName: content.holderName, expired: content.expired, ccv2: content.ccv2, userID: user.id ?? 0)
                    return paycard.save(on: req).map { _ in
                        return HTTPStatus.ok
                    }
                }
            }
        }
    }
    
    func delete(_ req: Request) throws -> Future<HTTPStatus> {
        let sessionId = req.http.headers.firstValue(name: HTTPHeaderName("X-Session-Id")) ?? ""
        guard let uuidSessionId = UUID(sessionId) else { throw Abort(.forbidden) }
        return Session.find(uuidSessionId, on: req).unwrap(or: Abort(.forbidden)).flatMap { session in
            return session.user.get(on: req).flatMap { user in
                return try req.parameters.next(Paycard.self).flatMap { paycard in
                    return paycard.delete(on: req)
                }.transform(to: .ok)
            }
        }
    }

}
