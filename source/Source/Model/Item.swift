import Foundation
import FirebaseFirestoreSwift

struct Item: Hashable, Codable {
    @DocumentID var id = UUID().uuidString
    var photos: [String]?
    let brandName: String
    let clothingName: String
    var description: String
    let category: String
    let color: String
    let sizes: [Size]
    
    enum CodingKeys: String, CodingKey {
        case id
        case photos
        case brandName = "brand_name"
        case clothingName = "clothing_name"
        case description
        case category
        case color
        case sizes
    }
}

// TODO: move to another place
extension Item {
    enum Sorting {
        case byIncreasePrice
        case byDecreasePrice
    }
}
