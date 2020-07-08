import Vapor

final class SignUpReply: Content {
    
    var appId: String
    var sessionId: String
    var transportKey: String
    
    init(appId: String, sessionId: String, transportKey: String) {
        self.appId = appId
        self.sessionId = sessionId
        self.transportKey = transportKey
    }
    
}
