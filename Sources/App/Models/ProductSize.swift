import FluentSQLite
import Vapor

final class ProductSize: SQLiteModel {
    typealias Database = SQLiteDatabase

    var id: Int?
    var name: String
    var price: Decimal
    var currency: String

    var productID: Int
    
    init(id: Int? = nil, name: String, price: Decimal, currency: String, productID: Int) {
        self.id = id
        self.name = name
        self.price = price
        self.currency = currency
        self.productID = productID
    }
}

extension ProductSize: Migration { }

extension ProductSize {
    var product: Parent<ProductSize, Product> {
        return parent(\.productID)
    }
}
