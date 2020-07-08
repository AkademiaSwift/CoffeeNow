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
        let session = Session(userID: nil)
        return session.save(on: req).map { createdSession in
            return SignInOneReply(entrophy: Session.randomTransportKey(length: 64), sessionId: createdSession.id?.uuidString ?? "", transportKey: createdSession.transportKey)
        }
    }
    
    func signincom(_ req: Request) throws -> Future<SignInTwoReply> {
        return try req.content.decode(SignInTwoRequest.self).flatMap { request in
            return User.query(on: req).filter(\User.appID, .equal, request.appId).first().unwrap(or: Abort(.notFound)).flatMap { user in
                return Piggy.query(on: req).filter(\Piggy.userID, .equal, user.id ?? -1).all().flatMap { piggies in
                    let balance = piggies.reduce(0.0, {$0 + $1.balance})
                    
                    let sessionId = req.http.headers.firstValue(name: HTTPHeaderName("X-Session-Id")) ?? ""
                    guard let uuidSessionId = UUID(sessionId) else { throw Abort(.forbidden) }
                    return Session.find(uuidSessionId, on: req).unwrap(or: Abort(.forbidden)).flatMap { session in
                        session.userID = user.id ?? -1
                        return session.save(on: req).map { _ in
                            
                            return SignInTwoReply(fullName: user.fullName, phoneNumber: user.phoneNumber, city: user.city, birthDay: user.birthDay, gender: user.gender, piggy: balance, currency: piggies.first?.currency ?? "PLN")
                            
                        }
                    }
                }
            }
        }
    }
    //3d63d22e-0dad-2ced-2fec-3a40cd09eff7
    
    func client(_ req: Request) throws -> Future<SignInTwoReply> {
        let sessionId = req.http.headers.firstValue(name: HTTPHeaderName("X-Session-Id")) ?? ""
        guard let uuidSessionId = UUID(sessionId) else { throw Abort(.forbidden) }
        return Session.find(uuidSessionId, on: req).unwrap(or: Abort(.forbidden)).flatMap { session in
            return session.user.get(on: req).flatMap { user in
                return Piggy.query(on: req).filter(\Piggy.userID, .equal, user.id ?? -1).all().map { piggies in
                    let balance = piggies.reduce(0.0, {$0 + $1.balance})
                    return SignInTwoReply(fullName: user.fullName, phoneNumber: user.phoneNumber, city: user.city, birthDay: user.birthDay, gender: user.gender, piggy: balance, currency: piggies.first?.currency ?? "PLN")
                }
            }
        }
    }
    
}
