import Vapor


final class PaycardAddTwoRequest: Content {
    
    var type: String
    var name: String
    var holderName: String
    var numberCrypto: String
    var expired: String
    var ccv2: String

    init(type: String, name: String, holderName: String, numberCrypto: String, expired: String, ccv2: String) {
        self.type = type
        self.name = name
        self.holderName = holderName
        self.numberCrypto = numberCrypto
        self.expired = expired
        self.ccv2 = ccv2
    }
    
}
