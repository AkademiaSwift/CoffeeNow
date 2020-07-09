import Vapor


final class PaycardListReply: Content {
    
    var id: Int
    var name: String
    var number: String
    var expired: String
    var type: String
    
    init(id: Int, name: String, number: String, expired: String, type: String) {
        self.id = id
        self.name = name
        if number.lengthOfBytes(using: .utf8) > 0 {
            let hashNumber = String(number.enumerated().map { $0 > 11 ? [$1] : ["*"] }.joined())
            let formattedNumber = String(hashNumber.enumerated().map { [4,8,12].contains($0) ? [" ", $1] : [$1]}.joined())
            self.number = formattedNumber.lowercased()
        } else {
            self.number = ""
        }
        self.expired = expired
        self.type = type
    }
    
}
