import FluentMySQL
import Vapor

final class Session: MySQLUUIDModel {
    typealias Database = MySQLDatabase
    
    var id: UUID?
    var transportKey: String
    var expired: Date
    var userID: Int?
    
    init(id: UUID? = nil, userID: Int?) {
        self.id = id
        self.userID = userID
        self.transportKey = Session.randomTransportKey(length: 48)
        self.expired = Date(timeIntervalSinceNow: 3600)
    }
    
    static func randomTransportKey(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map{ _ in letters.randomElement()! })
    }
}

extension Session: Migration { }
extension Session: Content { }
extension Session: Parameter { }

extension Session {
    var user: Parent<Session, User> {
        return parent(\.userID)!
    }
}
