import FluentMySQL
import Vapor

final class MenuCategory: MySQLModel {
    typealias Database = MySQLDatabase

    var id: Int?
    var name: String
    
    var coffeehouseID: Int
    
    init(id: Int? = nil, name: String, coffeehouseID: Int) {
        self.id = id
        self.name = name
        self.coffeehouseID = coffeehouseID
    }
}

extension MenuCategory: Migration { }

extension MenuCategory {
    var coffeehouse: Parent<MenuCategory, CoffeeHouse> {
        return parent(\.coffeehouseID)
    }
    var products: Siblings<MenuCategory, Product, MenuItem> {
        return siblings()
    }
}
