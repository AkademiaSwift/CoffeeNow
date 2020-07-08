import FluentSQLite
import Vapor

final class FavouriteOrderItem: SQLiteModel {
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

extension FavouriteOrderItem: Migration { }

extension FavouriteOrderItem {
    var order: Parent<FavouriteOrderItem, FavouriteOrder> {
        return parent(\.orderID)
    }
    var product: Parent<FavouriteOrderItem, Product> {
        return parent(\.productID)
    }
    var size: Parent<FavouriteOrderItem, ProductSize> {
        return parent(\.sizeID)!
    }
    var additionals: Children<FavouriteOrderItem, FavouriteOrderItemAdditional> {
        return children(\.orderItemID)
    }
}
