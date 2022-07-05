import Foundation
import FirebaseFirestoreSwift

// MARK: - UserDataProtocol
protocol UserDataProtocol {
    var id: String? { get set }
    var firstName: String? { get set }
    var lastName: String? { get set }
    var email: String? { get set }
    var details: UserDetails? { get set }
}

// MARK: - UserData
struct UserData: UserDataProtocol, Codable {
    var id: String?
    var firstName: String?
    var lastName: String?
    var email: String?
    var details: UserDetails?
    
    enum CodingKeys: String, CodingKey {
        case id
        case firstName = "first_name"
        case lastName = "last_name"
        case email
        case details = "details"
    }
}

// MARK: - UserDetails
struct UserDetails: Codable {
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
