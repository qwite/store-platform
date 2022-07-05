import FirebaseFirestoreSwift
import Foundation

struct Order: Codable, Hashable {
    @DocumentID var id = UUID().uuidString
    let userShippingAddress: String
    let userPhoneNumber: String
    let userFullName: String
    let brandId: String
    let item: CartItem
    let status: Status.RawValue
    let date: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case userShippingAddress = "user_shipping_address"
        case userPhoneNumber = "user_phone_number"
        case userFullName = "user_full_name"
        case brandId = "brand_id"
        case item
        case status
        case date
    }
}

extension Order {
    enum Status: String {
        case process = "process"
        case shipped = "shipped"
        case delivered = "delivered"
    }
}
