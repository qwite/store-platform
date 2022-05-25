import Foundation
import FirebaseFirestoreSwift

struct Size: Hashable, Identifiable, Codable {
    var id: String?
    let size: String?
    let price: Int?
    let amount: Int?
    
    enum AvailableSizes: String, CaseIterable {
        case xxs = "XXS"
        case xs = "XS"
        case s = "S"
        case m = "M"
        case l = "L"
        case xl = "XL"
        case xxl = "XXL"
    }
    
    init(size: String?, price: Int?, amount: Int?) {
        self.id = UUID().uuidString
        self.size = size
        self.price = price
        self.amount = amount
    }
}
