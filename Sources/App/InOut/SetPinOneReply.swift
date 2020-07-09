import Vapor


final class SetPinOneReply: Content {
    
    var entrophy: String
    
    init(entrophy: String) {
        self.entrophy = entrophy
    }
    
}
