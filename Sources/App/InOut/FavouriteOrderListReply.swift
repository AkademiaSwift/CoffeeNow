import Vapor

final class FavouriteOrderListReply: Content {
    
    var favouriteOrderId: Int
    var name: String
    var coffeehouseId: Int
    var localizationId: Int
    var orderAsap: Bool
    var orderTime: String?
    var items: [OrderItemReply]
    var totalAmount: Decimal
    var currency: String
    var paymentMethod: String
    var paycardId: Int?
    
    init(favouriteOrderId: Int, name: String, coffeehouseId: Int, localizationId: Int, orderAsap: Bool, orderTime: String?, items: [OrderItemReply], totalAmount: Decimal, currency: String, paymentMethod: String, paycardId: Int?) {
        self.favouriteOrderId = favouriteOrderId
        self.name = name
        self.coffeehouseId = coffeehouseId
        self.localizationId = localizationId
        self.orderAsap = orderAsap
        self.orderTime = orderTime
        self.items = items
        self.totalAmount = totalAmount
        self.currency = currency
        self.paymentMethod = paymentMethod
        self.paycardId = paycardId
    }
    
}
