import Foundation
import FirebaseFirestoreSwift


// MARK: - UserData
struct UserData: Codable {
    let id: String
    let firstName: String
    let lastName: String
    let email: String
    let details: UserDetails?
    
    init(id: String, firstName: String, lastName: String, email: String, details: UserDetails? = nil) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.details = details
    }
    
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
