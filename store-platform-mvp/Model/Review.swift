import Foundation
import FirebaseFirestoreSwift

// MARK: - Review
struct Review: Codable {
    @DocumentID var id = UUID().uuidString
    let text: String
    let rating: Double
    let userFirstName: String
    let userId: String
    
    enum CodingKeys: String, CodingKey {
        case text
        case rating
        case userFirstName = "user_first_name"
        case userId = "user_id"
    }
}
