import FluentMySQL
import Vapor

final class MenuItem: MySQLPivot {
    typealias Database = MySQLDatabase
    
    typealias Left = MenuCategory
    typealias Right = Product
    
    static var leftIDKey: LeftIDKey = \.menuCategoryID
    static var rightIDKey: RightIDKey = \.productID
    
    var id: Int?
    var menuCategoryID: Int
    var productID: Int
    
    init(id: Int? = nil, menuCategoryID: Int, productID: Int) {
        self.id = id
        self.menuCategoryID = menuCategoryID
        self.productID = productID
    }
}

extension MenuItem: Migration { }
