import Foundation
import FirebaseFirestoreSwift

protocol CustomUserProtocol {
    var id: String? { get set }
    var firstName: String? { get set }
    var lastName: String? { get set }
    var email: String? { get set }
}

struct CustomUser: CustomUserProtocol, Codable {
    var id: String?
    var firstName: String?
    var lastName: String?
    var email: String?
}
