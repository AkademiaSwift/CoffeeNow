import Vapor


final class OrderCreateCommitReply: Content {
    
    var orderId: String
    
    init(orderId: String) {
        self.orderId = orderId
    }
    
}
