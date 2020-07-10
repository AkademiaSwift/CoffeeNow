import Vapor


final class FavouriteOrderModifyRequest: Content {
    
    var name: String?
    var orderAsap: Bool?
    var orderTime: String?
    
    init(name: String?, orderAsap: Bool?, orderTime: String?) {
        self.name = name
        self.orderAsap = orderAsap
        self.orderTime = orderTime
    }
    
}
