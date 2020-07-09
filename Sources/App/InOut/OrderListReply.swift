import Vapor

class OrderItemReply: Codable {

    var productId: Int
    var sizeId: Int?
    var additionals: [Int]?
    var count: Int
    
    init(productId: Int, sizeId: Int?, additionals: [Int]?, count: Int) {
        self.productId = productId
        self.sizeId = sizeId
        self.additionals = additionals
        self.count = count
    }
    
}

final class OrderListReply: Content {
    
    var orderId: String
    var coffeehouseId: Int
    var localizationId: Int
    var orderAsap: Bool
    var orderTime: String?
    var items: [OrderItemReply]
    var totalAmount: Decimal
    var currency: String
    var paymentMethod: String
    var paycardId: Int?
    var status: String
    
    init(orderId: String, coffeehouseId: Int, localizationId: Int, orderAsap: Bool, orderTime: String?, items: [OrderItemReply], totalAmount: Decimal, currency: String, paymentMethod: String, paycardId: Int?, status: String) {
        self.orderId = orderId
        self.coffeehouseId = coffeehouseId
        self.localizationId = localizationId
        self.orderAsap = orderAsap
        self.orderTime = orderTime
        self.items = items
        self.totalAmount = totalAmount
        self.currency = currency
        self.paymentMethod = paymentMethod
        self.paycardId = paycardId
        self.status = status
    }
    
}
