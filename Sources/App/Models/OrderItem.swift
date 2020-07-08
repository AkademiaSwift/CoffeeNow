import FluentSQLite
import Vapor

final class OrderItem: SQLiteModel {
    typealias Database = SQLiteDatabase
    
    var id: Int?
    var orderID: Int
    var productID: Int
    var sizeID: Int?
    var count: Int

    init(id: Int? = nil, orderID: Int, productID: Int, sizeID: Int?, count: Int) {
        self.id = id
        self.orderID = orderID
        self.productID = productID
        self.sizeID = sizeID
        self.count = count
    }
}

extension OrderItem: Migration { }

extension OrderItem {
    var order: Parent<OrderItem, Order> {
        return parent(\.orderID)
    }
    var product: Parent<OrderItem, Product> {
        return parent(\.productID)
    }
    var size: Parent<OrderItem, ProductSize> {
        return parent(\.sizeID)!
    }
    var additionals: Children<OrderItem, OrderItemAdditional> {
        return children(\.orderItemID)
    }
}
