import Vapor


final class SignInTwoReply: Content {
    
    var fullName: String
    var phoneNumber: String?
    var city: String
    var birthDay: String?
    var gender: GenderType
    var photoBase: String?
    var piggy: Decimal
    var currency: String
    
    init(fullName: String, phoneNumber: String?, city: String, birthDay: String?, gender: GenderType, piggy: Decimal, currency: String, photoBase: String?) {
        self.fullName = fullName
        self.phoneNumber = phoneNumber
        self.city = city
        self.birthDay = birthDay
        self.gender = gender
        self.piggy = piggy
        self.currency = currency
        self.photoBase = photoBase
    }
    
}
