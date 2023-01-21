import Foundation
import FirebaseFirestoreSwift

struct Brand: Codable {
    @DocumentID var id = UUID().uuidString
    let brandName: String
    let description: String
    let logo: String
    let delivery: Delivery
    
    enum CodingKeys: String, CodingKey {
        case id
        case brandName = "brand_name"
        case description
        case logo
        case delivery
    }
}

struct Delivery: Codable {
    let city: String
    let firstName: String
    let lastName: String
    let patronymic: String
    
    enum CodingKeys: String, CodingKey {
        case city
        case firstName = "first_name"
        case lastName = "last_name"
        case patronymic
    }
}
