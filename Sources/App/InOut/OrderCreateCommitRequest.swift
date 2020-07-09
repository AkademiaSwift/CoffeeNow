import Vapor


final class OrderCreateCommitRequest: Content {
    
    var crypto: String
    
    init(crypto: String) {
        self.crypto = crypto
    }
    
}
