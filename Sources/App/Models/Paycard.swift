import FluentMySQL
import Vapor

final class Paycard: MySQLModel {
    typealias Database = MySQLDatabase
    
    var id: Int?
    var type: String
    var paycardName: String
    var paycardNumber: String
    var holderName: String
    var expired: String
    var ccv2: String
    var userID: Int
    
    init(id: Int? = nil, type: String, paycardName: String, paycardNumber: String, holderName: String, expired: String, ccv2: String, userID: Int) {
        self.id = id
        self.type = type
        self.paycardName = paycardName
        self.paycardNumber = paycardNumber
        self.holderName = holderName
        self.expired = expired
        self.ccv2 = ccv2
        self.userID = userID
    }
}

extension Paycard: Migration { }
extension Paycard: Parameter { }

extension Paycard {
    var user: Parent<Paycard, User> {
        return parent(\.userID)
    }
}
