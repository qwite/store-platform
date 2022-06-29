import Foundation
import FirebaseFirestoreSwift

protocol CustomUserProtocol {
    var id: String? { get set }
    var firstName: String? { get set }
    var lastName: String? { get set }
    var email: String? { get set }
    var details: DetailsUser? { get set }
}

struct UserData: CustomUserProtocol, Codable {
    var id: String?
    var firstName: String?
    var lastName: String?
    var email: String?
    var details: DetailsUser?
    
    enum CodingKeys: String, CodingKey {
        case id
        case firstName = "first_name"
        case lastName = "last_name"
        case email
        case details
    }
}

struct DetailsUser: Codable {
    let phone: String?
    let city: String?
    let street: String?
    let house: String?
    let apartment: String?
    let postalCode: String?
    
    enum CodingKeys: String, CodingKey {
        case phone
        case city
        case street
        case house
        case apartment
        case postalCode = "postal_code"
    }
}
