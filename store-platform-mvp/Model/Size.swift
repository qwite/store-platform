import Foundation
import FirebaseFirestoreSwift

struct Size: Hashable, Identifiable, Codable {
    var id: String
    let size: String
    let price: Int
    let amount: Int
        
    init(size: AvailableSizes, price: Int, amount: Int) {
        self.id = UUID().uuidString
        self.size = size.rawValue
        self.price = price
        self.amount = amount
    }
}

// MARK: - AvailableSizes
extension Size {
    enum AvailableSizes: String, CaseIterable {
        case xxs
        case xs
        case s
        case m
        case l
        case xl
        case xxl
    }
}
