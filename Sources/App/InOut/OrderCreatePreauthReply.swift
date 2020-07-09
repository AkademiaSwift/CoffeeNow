import Vapor


final class OrderCreatePreauthReply: Content {
    
    var entrophy: String
    
    init(entrophy: String) {
        self.entrophy = entrophy
    }
    
}
