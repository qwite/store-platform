import Foundation

// MARK: - Cart
struct Cart: Hashable, Codable {
    let itemId: String
    let selectedSize: String
    let selectedPrice: Int
}

// MARK: - CodingKeys
extension Cart {
    enum CodingKeys: String, CodingKey {
        case itemId = "item_id"
        case selectedSize = "selected_size"
        case selectedPrice = "selected_price"
    }
}

