import FluentSQLite
import Vapor

final class MenuItem: SQLitePivot {
    typealias Database = SQLiteDatabase
    
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
