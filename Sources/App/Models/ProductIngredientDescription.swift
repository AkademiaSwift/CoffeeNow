import FluentSQLite
import Vapor

final class ProductIngredientDescription: SQLiteModel {
    typealias Database = SQLiteDatabase

    var id: Int?
    var name: String
    var description: String

    var productID: Int
    
    init(id: Int? = nil, name: String, description: String, productID: Int) {
        self.id = id
        self.name = name
        self.description = description
        self.productID = productID
    }
}

extension ProductIngredientDescription: Migration { }

extension ProductIngredientDescription {
    var product: Parent<ProductIngredientDescription, Product> {
        return parent(\.productID)
    }
}
