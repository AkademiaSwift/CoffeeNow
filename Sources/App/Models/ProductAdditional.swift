import FluentMySQL
import Vapor

final class ProductAdditional: MySQLModel {
    typealias Database = MySQLDatabase

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

extension ProductAdditional: Migration { }

extension ProductAdditional {
    var product: Parent<ProductAdditional, Product> {
        return parent(\.productID)
    }
}
