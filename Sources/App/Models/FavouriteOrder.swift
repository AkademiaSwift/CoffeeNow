import FluentSQLite
import Vapor

final class FavouriteOrder: SQLiteModel {
    typealias Database = SQLiteDatabase
    
    var id: Int?
    var name: String
    var userID: Int
    var coffeehouseID: Int
    var localizationID: Int
    var orderAsap: Bool
    var orderTime: String?
    var totalAmount: Decimal
    var currency: String
    var paymentMethod: PaymentMethodType
    var paycardID: Int?
    var status: OrderStatusType
    
    init(id: Int? = nil, userID: Int, coffeehouseID: Int, localizationID: Int, name:String, orderAsap: Bool, orderTime: String?, totalAmount: Decimal, currency: String = "PLN", paymentMethod: PaymentMethodType, paycardID: Int?, status: OrderStatusType = .waiting) {
        self.id = id
        self.name = name
        self.userID = userID
        self.coffeehouseID = coffeehouseID
        self.localizationID = localizationID
        self.orderAsap = orderAsap
        self.orderTime = orderTime
        self.totalAmount = totalAmount
        self.currency = currency
        self.paymentMethod = paymentMethod
        self.paycardID = paycardID
        self.status = status
    }
}

extension FavouriteOrder: Migration { }

extension FavouriteOrder {
    var user: Parent<FavouriteOrder, User> {
        return parent(\.userID)
    }
    var paycard: Parent<FavouriteOrder, Paycard> {
        return parent(\.paycardID)!
    }
    var items: Children<FavouriteOrder, FavouriteOrderItem> {
        return children(\.orderID)
    }
}
