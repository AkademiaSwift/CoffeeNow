import Vapor

struct PLAddress: Codable {
    var city: String
    var postalCode: String
    var post: String?
    var street: String?
    var house: String
    var flat: String?
}

struct GSMLocation: Codable {
    var latitude: Double
    var longitude: Double
}

final class CoffeeHouseLocationReply: Content {
    var id: Int
    var name: String
    var address: PLAddress
    var phone: String
    var location: GSMLocation
    
    init(location: Location) {
        self.id = location.id ?? 0
        self.name = location.name
        self.address = PLAddress(city: location.city, postalCode: location.postalCode, post: location.post, street: location.street, house: location.house, flat: location.flat)
        self.phone = location.phone ?? ""
        self.location = GSMLocation(latitude: Double(location.latitude) ?? 0.0, longitude: Double(location.longitude) ?? 0.0)
    }
}




