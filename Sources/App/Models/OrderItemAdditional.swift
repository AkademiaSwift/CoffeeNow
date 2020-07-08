import FluentSQLite
import Vapor

final class OrderItemAdditional: SQLiteModel {
    typealias Database = SQLiteDatabase
    
    var id: Int?
    var orderItemID: Int
    var additionalID: Int

    init(id: Int? = nil, orderItemID: Int, additionalID: Int) {
        self.id = id
        self.orderItemID = orderItemID
        self.additionalID = additionalID
    }
}

extension OrderItemAdditional: Migration { }

extension OrderItemAdditional {
    var orderItem: Parent<OrderItemAdditional, OrderItem> {
        return parent(\.orderItemID)
    }
    var additional: Parent<OrderItemAdditional, ProductAdditional> {
        return parent(\.additionalID)
    }
}
