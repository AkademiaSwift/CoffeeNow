import FluentMySQL
import Vapor

final class Location: MySQLModel {
    typealias Database = MySQLDatabase

    var id: Int?
    var name: String
    var city: String
    var postalCode: String
    var street: String?
    var house: String
    var flat: String?
    var post: String?
    var phone: String?
    var latitude: String
    var longitude: String
    
    var coffeehouseID: Int

    init(id: Int? = nil, name: String, city: String, postalCode: String, street: String?, house: String, flat: String?, post: String?, phone: String?, latitude: String, longitude: String, coffeehouseID: Int) {
        self.id = id
        self.name = name
        self.city = city
        self.postalCode = postalCode
        self.street = street
        self.house = house
        self.flat = flat
        self.phone = phone
        self.latitude = latitude
        self.longitude = longitude
        self.coffeehouseID = coffeehouseID
    }
}

extension Location: Migration { }

extension Location {
    var coffeehouse: Parent<Location, CoffeeHouse> {
        return parent(\.coffeehouseID)
    }
}
