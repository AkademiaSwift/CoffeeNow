import Vapor


final class SignInTwoRequest: Content {
    
    var appId: String
    var crypto: String
    
    init(appId: String, crypto: String) {
        self.appId = appId
        self.crypto = crypto
    }
    
}
