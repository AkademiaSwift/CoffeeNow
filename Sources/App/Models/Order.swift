import FluentMySQL
import Vapor

enum PaymentMethodType: String {
    case unknown = ""
    case piggy = "PIGGY"
    case paycard = "CARD"
    case blik = "BLIK"
    case paypal = "PAYPAL"
}

extension PaymentMethodType: Codable {
    enum Key: CodingKey {
        case rawValue
    }
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Key.self)
        let rawValue = try container.decode(String.self, forKey: .rawValue)
        switch rawValue {
            case "PIGGY":
                self = .piggy
            case "CARD":
                self = .paycard
            case "BLIK":
                self = .blik
            case "PAYPAL":
                self = .paypal
            default:
                self = .unknown
        }
    }
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Key.self)
        switch self {
            case .piggy:
                try container.encode("PIGGY", forKey: .rawValue)
            case .paypal:
                try container.encode("PAYPAL", forKey: .rawValue)
            case .blik:
                try container.encode("BLIK", forKey: .rawValue)
            case .paycard:
                try container.encode("CARD", forKey: .rawValue)
            case .unknown:
                try container.encode("", forKey: .rawValue)
        }
    }
}

enum OrderStatusType: String {
    case done = "DONE"
    case waiting = "WAITING"
    case cancelled = "CANCELLED"
}

extension OrderStatusType: Codable {
    enum Key: CodingKey {
        case rawValue
    }
    enum CodingError: Error {
        case unknownValue
    }
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Key.self)
        let rawValue = try container.decode(String.self, forKey: .rawValue)
        switch rawValue {
            case "DONE":
                self = .done
            case "CANCELLED":
                self = .cancelled
            default:
                self = .waiting
        }
    }
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Key.self)
        switch self {
            case .done:
                try container.encode("DONE", forKey: .rawValue)
            case .waiting:
                try container.encode("WAITING", forKey: .rawValue)
            case .cancelled:
                try container.encode("CANCELLED", forKey: .rawValue)
        }
    }
}

final class Order: MySQLModel {
    typealias Database = MySQLDatabase
    
    var id: Int?
    var orderId: String
    var createdAt: Date
    var userID: Int
    var coffeehouseID: Int
    var localizationID: Int
    var orderAsap: Bool
    var orderTime: String?
    var totalAmount: Decimal
    var currency: String
    var paymentMethod: PaymentMethodType
    var paycardID: Int?
    var status: OrderStatusType
    
    init(id: Int? = nil, userID: Int, coffeehouseID: Int, localizationID: Int, orderAsap: Bool, orderTime: String?, totalAmount: Decimal, currency: String = "PLN", paymentMethod: PaymentMethodType, paycardID: Int?, status: OrderStatusType = .waiting) {
        self.id = id
        self.orderId = Order.randomOrderID(length: 14)
        self.createdAt = Date()
        self.userID = userID
        self.coffeehouseID = coffeehouseID
        self.localizationID = localizationID
        self.orderAsap = orderAsap
        self.orderTime = orderTime
        self.totalAmount = totalAmount
        self.currency = currency
        self.paymentMethod = paymentMethod
        self.paycardID = paycardID
        self.status = status
    }
    
    static func randomOrderID(length: Int) -> String {
        let letters = "abcdefABCDEF0123456789"
        let result = String((0..<length).map{ _ in letters.randomElement()! })
        return String(result.enumerated().map { $0 > 0 && [4, 7, 10].contains($0) ? ["-", $1] : [$1]}.joined()).lowercased()
    }
}

extension Order: Migration { }

extension Order {
    var user: Parent<Order, User> {
        return parent(\.userID)
    }
    var paycard: Parent<Order, Paycard> {
        return parent(\.paycardID)!
    }
    var items: Children<Order, OrderItem> {
        return children(\.orderID)
    }
}
