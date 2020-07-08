import FluentSQLite
import Vapor

final class Product: SQLiteModel {
    typealias Database = SQLiteDatabase

    var id: Int?
    var name: String
    var photoUrl: String
    var shortDescription: String
    var fullDescription: String

    init(id: Int? = nil, name: String, photoUrl: String, shortDescription: String, fullDescription: String) {
        self.id = id
        self.name = name
        self.photoUrl = photoUrl
        self.shortDescription = shortDescription
        self.fullDescription = fullDescription
    }
}

extension Product: Migration { }

extension Product {
    var ingredients: Children<Product, ProductIngredient> {
        return children(\.productID)
    }
    var ingredientDescriptions: Children<Product, ProductIngredientDescription> {
        return children(\.productID)
    }
    var sizes: Children<Product, ProductSize> {
        return children(\.productID)
    }
    var additionals: Children<Product, ProductAdditional> {
        return children(\.productID)
    }
    var menuCategories: Siblings<Product, MenuCategory, MenuItem> {
        return siblings()
    }
}
