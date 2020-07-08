import Vapor


final class SignInOneReply: Content {
    
    var entrophy: String
    var sessionId: String
    var transportKey: String
    
    init(entrophy: String, sessionId: String, transportKey: String) {
        self.entrophy = entrophy
        self.sessionId = sessionId
        self.transportKey = transportKey
    }
    
}
