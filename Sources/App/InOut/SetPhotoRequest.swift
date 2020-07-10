import Vapor


final class SetPhotoRequest: Content {
    
    var photo: String
    
    init(photo: String) {
        self.photo = photo
    }
    
}
