import FluentMySQL
import Vapor

final class FavouriteCoffeeHouse: MySQLPivot {
    typealias Database = MySQLDatabase
    
    typealias Left = CoffeeHouse
    typealias Right = User
    
    static var leftIDKey: LeftIDKey = \.coffeeHouseID
    static var rightIDKey: RightIDKey = \.userID
    
    var id: Int?
    var userID: Int
    var coffeeHouseID: Int

    init(id: Int? = nil, coffeeHouseID: Int, userID: Int) {
        self.id = id
        self.coffeeHouseID = coffeeHouseID
        self.userID = userID
    }
}

extension FavouriteCoffeeHouse: Migration { }
