import FluentMySQL
import Vapor

enum GenderType: String {
    case unknown = ""
    case male = "MALE"
    case female = "FEMALE"
}

extension GenderType: Codable {
    enum Key: CodingKey {
        case rawValue
    }
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Key.self)
        let rawValue = try container.decode(String.self, forKey: .rawValue)
        switch rawValue {
            case "MALE":
                self = .male
            case "FEMALE":
                self = .female
            default:
                self = .unknown
        }
    }
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Key.self)
        switch self {
            case .male:
                try container.encode("MALE", forKey: .rawValue)
            case .female:
                try container.encode("FEMALE", forKey: .rawValue)
            case .unknown:
                try container.encode("", forKey: .rawValue)
        }
    }
}

final class User: MySQLModel {
    typealias Database = MySQLDatabase

    var id: Int?
    var appID: String
    var fullName: String
    var phoneNumber: String?
    var city: String
    var birthDay: String?
    var gender: GenderType
    var photoBase: String
    var pin: String

    init(id: Int? = nil, fullName: String, phoneNumber: String?, city: String, birthDay: String?, gender: GenderType, photoBase: Data?) {
        self.id = id
        self.appID = User.randomAppID(length: 32)
        self.fullName = fullName
        self.phoneNumber = phoneNumber
        self.city = city
        self.birthDay = birthDay
        self.gender = gender
        if let photo = photoBase {
            self.photoBase = photo.base64EncodedString()
        } else {
            self.photoBase = ""
        }
        self.pin = ""
    }
    
    static func randomAppID(length: Int) -> String {
        let letters = "abcdefABCDEF0123456789"
        let result = String((0..<length).map{ _ in letters.randomElement()! })
        return String(result.enumerated().map { $0 > 0 && [8, 12, 16, 20].contains($0) ? ["-", $1] : [$1]}.joined()).lowercased()
    }
}

extension User: Migration { }

extension User {
    var sessions: Children<User, Session> {
        return children(\.userID)
    }
    var piggies: Children<User, Piggy> {
        return children(\.userID)
    }
    var paycards: Children<User, Paycard> {
        return children(\.userID)
    }
    var orders: Children<User, Order> {
        return children(\.userID)
    }
    var favouriteOrders: Children<User, FavouriteOrder> {
        return children(\.userID)
    }
}
