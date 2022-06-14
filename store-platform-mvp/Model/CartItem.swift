import Foundation
import FirebaseFirestoreSwift

struct CartItem: Hashable, Codable {
    let item: Item
    let selectedSize: String
    let selectedPrice: Int
}

extension CartItem {
    enum CodingKeys: String, CodingKey {
        case item = "item"
        case selectedSize = "selected_size"
        case selectedPrice = "selected_price"
    }
}
