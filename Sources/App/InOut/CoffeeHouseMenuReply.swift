import Vapor

struct ProductIngredientReply: Codable {
    var name: String
    var color: String
}

struct ProductSizeReply: Codable {
    var id: Int
    var name: String
    var price: Decimal
    var currency: String
}

struct ProductAdditionalReply: Codable {
    var id: Int
    var name: String
    var price: Decimal
    var currency: String
}

struct ProductShortReply: Codable {
    var id: Int
    var name: String
    var photoUrl: String
    var shortDescription: String
    var ingredients: [ProductIngredientReply]
    var sizes: [ProductSizeReply]
    var additionals: [ProductAdditionalReply]
}

struct CoffeeHouseMenu: Codable {
    var id: Int
    var name: String
    var products: [ProductShortReply]
}

final class CoffeeHouseMenuReply: Content {
    var categories: [CoffeeHouseMenu]
    init(categories: [CoffeeHouseMenu]) {
        self.categories = categories
    }
}
