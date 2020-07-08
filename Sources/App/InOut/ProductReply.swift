import Vapor

struct ProductIngredientDescriptionReply: Codable {
    var name: String
    var description: String
    
    init(ingredient: ProductIngredientDescription) {
        self.name = ingredient.name
        self.description = ingredient.description
    }
}

final class ProductReply: Content {
    var id: Int
    var name: String
    var photoUrl: String
    var description: String
    var ingredeintsDescriptions: [ProductIngredientDescriptionReply]
    
    init(product: Product, ingredients: [ProductIngredientDescription]) {
        self.id = product.id ?? 0
        self.name = product.name
        self.photoUrl = product.photoUrl
        self.description = product.fullDescription
        self.ingredeintsDescriptions = ingredients.map {
            return ProductIngredientDescriptionReply(ingredient: $0)
        }
    }
}
