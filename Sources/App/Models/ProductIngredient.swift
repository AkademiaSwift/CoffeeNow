import FluentMySQL
import Vapor

final class ProductIngredient: MySQLModel {
    typealias Database = MySQLDatabase

    var id: Int?
    var name: String
    var color: String

    var productID: Int
    
    init(id: Int? = nil, name: String, color: String, productID: Int) {
        self.id = id
        self.name = name
        self.color = color
        self.productID = productID
    }
}

extension ProductIngredient: Migration { }

extension ProductIngredient {
    var product: Parent<ProductIngredient, Product> {
        return parent(\.productID)
    }
}
