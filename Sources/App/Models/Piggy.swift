import FluentSQLite
import Vapor

final class Piggy: SQLiteModel {
    typealias Database = SQLiteDatabase
    
    var id: Int?
    var balance: Decimal
    var currency: String
    var createdAt: Date
    var userID: Int
    
    init(id: Int? = nil, balance: Decimal, currency: String = "PLN", userID: Int) {
        self.id = id
        self.balance = balance
        self.currency = currency
        self.createdAt = Date()
        self.userID = userID
    }
}

extension Piggy: Migration { }
extension Piggy: Content { }
extension Piggy: Parameter { }

extension Piggy {
    var user: Parent<Piggy, User> {
        return parent(\.userID)
    }
}
