import FluentSQLite
import Vapor

final class FavouriteOrderItemAdditional: SQLiteModel {
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

extension FavouriteOrderItemAdditional: Migration { }

extension FavouriteOrderItemAdditional {
    var orderItem: Parent<FavouriteOrderItemAdditional, FavouriteOrderItem> {
        return parent(\.orderItemID)
    }
    var additional: Parent<FavouriteOrderItemAdditional, ProductAdditional> {
        return parent(\.additionalID)
    }
}
