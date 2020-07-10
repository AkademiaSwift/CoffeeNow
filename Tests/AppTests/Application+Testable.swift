//
//  Application+Testable.swift
//  App
//
//  Created by Pawel Szenk on 09/07/2020.
//

import Foundation
import Vapor

extension Application {
    
    public static func testable() throws -> Application {
         var config = Config.default()
         var services = Services.default()
         var env = Environment.testing
         try App.configure(&config, &env, &services)
         let app = try Application(config: config, environment: env, services: services)
         try App.boot(app)

         return app
    }
    
    public func sendRequest<Body>(to path: String, method: HTTPMethod, headers: HTTPHeaders = .init(), body: Body?) throws -> Response where Body: Content {
        let httpRequest = HTTPRequest(method: method, url: URL(string: path)!, headers: headers)
        let wrappedRequest = Request(http: httpRequest, using: self)
        if let body = body {
            try wrappedRequest.content.encode(body)
        }
        print("==============================")
        print("Send Request:")
        print(wrappedRequest)
        print("------------------------------")
        let responder = try make(Responder.self)
        let result = try responder.respond(to: wrappedRequest).wait()
        print("------------------------------")
        print("Reply:")
        print(result)
        return result
    }
    
    public func signIn(appId: String, pin: String) throws -> (String, String)? {
        let empty: EmptyBody? = nil
        let test = try self.sendRequest(to: "signin", method: .GET, body: empty)
        let firstStepReply = try test.content.decode(SignInOneReply.self).wait()
        
        guard let crypto = try CryptoUtils.encodePin(pin: pin, key: firstStepReply.transportKey, entrophy: firstStepReply.entrophy) else { return nil }
        let user: SignInTwoRequest = SignInTwoRequest(appId: appId, crypto: crypto)
        var headers = HTTPHeaders()
        headers.add(name: "X-Session-Id", value: firstStepReply.sessionId)
        _ = try self.sendRequest(to: "signin", method: .POST, headers: headers, body: user)
        return (firstStepReply.sessionId, firstStepReply.transportKey)
    }
    
}

public struct EmptyBody: Content {}
