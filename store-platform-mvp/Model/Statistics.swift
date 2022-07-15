import Foundation

struct Statistics: Codable, Hashable {
    let monthlyViews: [MonthlyViews]
    
    enum CodingKeys: String, CodingKey {
        case monthlyViews = "monthly_views"
    }
}

struct MonthlyViews: Codable, Hashable {
    let month: String
    let day: Int
    let amount: Int
    
    init(month: String, day: Int) {
        self.month = month
        self.day = day
        self.amount = 1
    }
}

// FIXME: views + item
struct ItemViews: Hashable {
    let item: Item
    let views: Int
}

struct Sales: Codable, Hashable {
    let item: String
    let count: Int
    
    enum CodingKeys: String, CodingKey {
        case item
        case count
    }
}

struct SalesPrice: Hashable {
    let month: String
    let price: Int
}

struct Finance: Hashable {
    let totalPrice: Int
}


