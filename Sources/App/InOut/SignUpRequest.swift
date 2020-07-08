import Vapor

final class SignUpRequest: Content {
    
    var fullName: String
    var phoneNumber: String
    var city: String
    var birthDay: String
    var gender: String
 
    init(fullName: String, phoneNumber: String, city: String, birthDay: String, gender: String) {
        self.fullName = fullName
        self.phoneNumber = phoneNumber
        self.city = city
        self.birthDay = birthDay
        self.gender = gender
    }
    
}
