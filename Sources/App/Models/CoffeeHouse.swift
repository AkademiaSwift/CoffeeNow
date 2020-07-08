import FluentMySQL
import Vapor

final class CoffeeHouse: MySQLModel {
    typealias Database = MySQLDatabase

    var id: Int?
    var name: String
    var website: String
    var logoURL: String

    init(id: Int? = nil, name: String, website: String, logoURL: String) {
        self.id = id
        self.name = name
        self.website = website
        self.logoURL = logoURL
    }
}

extension CoffeeHouse: Migration { }
extension CoffeeHouse: Content { }
extension CoffeeHouse: Parameter { }

extension CoffeeHouse {
    var locations: Children<CoffeeHouse, Location> {
        return children(\.coffeehouseID)
    }
    var menus: Children<CoffeeHouse, MenuCategory> {
        return children(\.coffeehouseID)
    }
}
