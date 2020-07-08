import FluentMySQL
import Vapor

final class OrderItemAdditional: MySQLModel {
    typealias Database = MySQLDatabase
    
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
