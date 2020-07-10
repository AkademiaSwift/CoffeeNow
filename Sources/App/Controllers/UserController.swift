import Vapor


final class UserController {

    func signup(_ req: Request) throws -> Future<SignUpReply> {
        return try req.content.decode(SignUpRequest.self).flatMap { request in
            let user = User(fullName: request.fullName, phoneNumber: request.phoneNumber, city: request.city, birthDay: request.birthDay, gender: GenderType(rawValue: request.gender) ?? .unknown, photoBase: nil)
            return user.save(on: req).flatMap { createdUser in
                let session = Session(userID: createdUser.id)
                return session.save(on: req).map { createdSession in
                    return SignUpReply(appId: createdUser.appID, sessionId: createdSession.id?.uuidString ?? "", transportKey: createdSession.transportKey)
                }
            }
        }
    }
    
    func signinpre(_ req: Request) throws -> Future<SignInOneReply> {
        let cache = try req.make(MySQLCache.self)
        let session = Session(userID: nil)
        let entrophy = Session.randomTransportKey(length: 64)
        return session.save(on: req).flatMap { createdSession in
            let sessionId = createdSession.id?.uuidString ?? ""
            return cache.set("signInEntrophy-\(sessionId)", to: entrophy).map { _ in
                return SignInOneReply(entrophy: entrophy, sessionId: sessionId, transportKey: createdSession.transportKey)
            }
        }
    }
    
    func signincom(_ req: Request) throws -> Future<SignInTwoReply> {
        return try req.content.decode(SignInTwoRequest.self).flatMap { request in
            let sessionId = req.http.headers.firstValue(name: HTTPHeaderName("X-Session-Id")) ?? ""
            guard let uuidSessionId = UUID(sessionId) else { throw Abort(.forbidden) }
            return Session.find(uuidSessionId, on: req).unwrap(or: Abort(.forbidden)).flatMap { session in
                let cache = try req.make(MySQLCache.self)
                return cache.get("signInEntrophy-\(sessionId)", as: String.self).unwrap(or: Abort(.notFound)).flatMap { entrophy in
                    guard let pin = try CryptoUtils.decodePin(encodedString: request.crypto, key: session.transportKey, entrophy: entrophy) else {
                        throw Abort(.badRequest)
                    }
                    return User.query(on: req).filter(\User.appID, .equal, request.appId).filter(\User.pin, .equal, pin).first().unwrap(or: Abort(.notFound)).flatMap { user in
            
                        return Piggy.query(on: req).filter(\Piggy.userID, .equal, user.id ?? -1).all().flatMap { piggies in
                            let balance = piggies.reduce(0.0, {$0 + $1.balance})
                            session.userID = user.id ?? -1
                            return session.save(on: req).map { _ in
                                
                                return SignInTwoReply(fullName: user.fullName, phoneNumber: user.phoneNumber, city: user.city, birthDay: user.birthDay, gender: user.gender, piggy: balance, currency: piggies.first?.currency ?? "PLN", photoBase: user.photoBase)
                                
                            }
                        }
                    }
                }
            }
        }
    }

    func client(_ req: Request) throws -> Future<SignInTwoReply> {
        let sessionId = req.http.headers.firstValue(name: HTTPHeaderName("X-Session-Id")) ?? ""
        guard let uuidSessionId = UUID(sessionId) else { throw Abort(.forbidden) }
        return Session.find(uuidSessionId, on: req).unwrap(or: Abort(.forbidden)).flatMap { session in
            return session.user.get(on: req).flatMap { user in
                return Piggy.query(on: req).filter(\Piggy.userID, .equal, user.id ?? -1).all().map { piggies in
                    let balance = piggies.reduce(0.0, {$0 + $1.balance})
                    return SignInTwoReply(fullName: user.fullName, phoneNumber: user.phoneNumber, city: user.city, birthDay: user.birthDay, gender: user.gender, piggy: balance, currency: piggies.first?.currency ?? "PLN", photoBase: user.photoBase)
                }
            }
        }
    }
    
    func setpinpre(_ req: Request) throws -> Future<SetPinOneReply> {
        let cache = try req.make(MySQLCache.self)
        let sessionId = req.http.headers.firstValue(name: HTTPHeaderName("X-Session-Id")) ?? ""
        let entrophy = Session.randomTransportKey(length: 64)
        guard let uuidSessionId = UUID(sessionId) else { throw Abort(.forbidden) }
        return Session.find(uuidSessionId, on: req).unwrap(or: Abort(.forbidden)).flatMap { session in
            return cache.set("setPinEntrophy-\(sessionId)", to: entrophy).map { _ in
                return SetPinOneReply(entrophy: entrophy)
            }
        }
    }
    
    func setpincom(_ req: Request) throws -> Future<HTTPStatus> {
        let sessionId = req.http.headers.firstValue(name: HTTPHeaderName("X-Session-Id")) ?? ""
        guard let uuidSessionId = UUID(sessionId) else { throw Abort(.forbidden) }
        return Session.find(uuidSessionId, on: req).unwrap(or: Abort(.forbidden)).flatMap { session in
            return session.user.get(on: req).flatMap { user in
                let cache = try req.make(MySQLCache.self)
                return cache.get("setPinEntrophy-\(sessionId)", as: String.self).unwrap(or: Abort(.notFound)).flatMap { entrophy in
                    return try req.content.decode(SetPinTwoRequest.self).flatMap { content in
                        guard let pin = try CryptoUtils.decodePin(encodedString: content.crypto, key: session.transportKey, entrophy: entrophy) else {
                            throw Abort(.badRequest)
                        }
                        user.pin = pin
                        return user.save(on: req).flatMap { _ in
                            return cache.remove("setPinEntrophy-\(sessionId)").map { _ in
                                return HTTPStatus.ok
                            }
                        }
                    }
                }
            }
        }
    }
    
    func setphoto(_ req: Request) throws -> Future<HTTPStatus> {
        let sessionId = req.http.headers.firstValue(name: HTTPHeaderName("X-Session-Id")) ?? ""
        guard let uuidSessionId = UUID(sessionId) else { throw Abort(.forbidden) }
        return Session.find(uuidSessionId, on: req).unwrap(or: Abort(.forbidden)).flatMap { session in
            return session.user.get(on: req).flatMap { user in
                return try req.content.decode(SetPinTwoRequest.self).flatMap { content in
                    user.photoBase = ""
                    return user.save(on: req).map { _ in
                        return HTTPStatus.ok
                    }
                }
            }
        }
    }
    

}
