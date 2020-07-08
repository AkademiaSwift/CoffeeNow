import FluentSQLite
import Vapor

final class Paycard: SQLiteModel {
    typealias Database = SQLiteDatabase
    
    var id: Int?
    var type: String
    var paycardNumber: String
    var expired: String
    var ccv2: String
    var userID: Int
    
    init(id: Int? = nil, type: String, paycardNumber: String, expired: String, ccv2: String, userID: Int) {
        self.id = id
        self.type = type
        self.paycardNumber = paycardNumber
        self.expired = expired
        self.ccv2 = ccv2
        self.userID = userID
    }
}

extension Paycard: Migration { }

extension Paycard {
    var user: Parent<Paycard, User> {
        return parent(\.userID)
    }
}
