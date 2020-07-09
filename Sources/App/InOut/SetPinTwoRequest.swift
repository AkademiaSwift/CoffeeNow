import Vapor


final class SetPinTwoRequest: Content {
    
    var crypto: String
    
    init(crypto: String) {
        self.crypto = crypto
    }
    
}
