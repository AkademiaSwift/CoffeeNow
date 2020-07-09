import Vapor


final class PaycardAddOneReply: Content {
    
    var entrophy: String
    
    init(entrophy: String) {
        self.entrophy = entrophy
    }
    
}
