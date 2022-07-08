import UIKit
import FirebaseFirestore
import FirebaseAuth
import FirebaseFirestoreSwift

protocol FeedServiceProtocol {
    func fetchAllItems(by sort: Item.Sorting?, completion: @escaping (Result<[Item], Error>) -> ())
    func fetchItemsByCategory(category: String, completion: @escaping (Result<[Item], Error>) -> ())
    func fetchItemsByBrandName(brand: String, completion: @escaping (Result<[Item], Error>) -> ())
    func fetchPopularItems(completion: @escaping (Result<[Int: [String: Any]], Error>) -> ())
}

class FeedService: FeedServiceProtocol {
    private let firebaseDb = Firestore.firestore()
    
    /// Items reference
    private var itemsReference: CollectionReference {
        return firebaseDb.collection("items")
    }
    
    /// Fetching all items. Optional sorting. Returns [Item]
    func fetchAllItems(by sort: Item.Sorting? = nil, completion: @escaping (Result<[Item], Error>) -> ()) {
        itemsReference.getDocuments { snapshot, error in
            guard let snapshot = snapshot,
                  !snapshot.isEmpty else {
                completion(.failure(error!)); return
            }
            
            let documents = snapshot.documents
            let resultItems = documents.compactMap { querySnapshot in
                return try? querySnapshot.data(as: Item.self)
            }
            
            guard let sortingOption = sort else {
                completion(.success(resultItems)); return
            }
            
            // Sorting items
            let resultSortedItems: [Item] = resultItems.sorted { firstItem, secondItem in
                guard let firstPrice = firstItem.sizes?.first?.price,
                      let secondPrice = secondItem.sizes?.first?.price else {
                    return false
                }
                
                switch sortingOption {
                case .byIncreasePrice:
                    return secondPrice > firstPrice
                case .byDecreasePrice:
                    return secondPrice < firstPrice
                }
            }
            
            completion(.success(resultSortedItems))
        }
    }
    
    /// Fetching items by clothing category. Returns [Item]
    func fetchItemsByCategory(category: String, completion: @escaping (Result<[Item], Error>) -> ()) {
        itemsReference.whereField("category", isEqualTo: category).getDocuments { querySnapshot, error in
            guard let snapshot = querySnapshot, !snapshot.isEmpty else {
                completion(.failure(AdsServiceError.documentNotFound)); return
            }
            
            let documents: [Item] = snapshot.documents.compactMap { snap in
                guard let item = try? snap.data(as: Item.self) else { return nil }
                return item
            }
            
            completion(.success(documents))
        }
    }
    
    /// Fetching items by brand name. Returns [Item]
    func fetchItemsByBrandName(brand: String, completion: @escaping (Result<[Item], Error>) -> ()) {
        let brandLowerCased = brand.lowercased()
        itemsReference.whereField("brand_name", isEqualTo: brandLowerCased).getDocuments { querySnapshot, error in
            guard let snapshot = querySnapshot, !snapshot.isEmpty else {
                completion(.failure(AdsServiceError.documentNotFound)); return
            }
            
            let documents: [Item] = snapshot.documents.compactMap { snap in
                guard let item = try? snap.data(as: Item.self) else { return nil }
                return item
            }
            
            completion(.success(documents))
        }
    }
    
    // TODO: refactor
    func fetchPopularItems(completion: @escaping (Result<[Int: [String: Any]], Error>) -> ()) {
        itemsReference.getDocuments { querySnapshot, error in
            guard let snapshot = querySnapshot,
                  !snapshot.isEmpty else {
                return completion(.failure(AdsServiceError.documentNotFound))
            }
            
            let group = DispatchGroup()
            /*
             Result:
             "itemId":
             "item": Item,
             "views": [
             monthlyData,
             monthlyData,
             ...
             ]
             
             */
            
            let documents = snapshot.documents
            var resultDictionary: [Int: [String: Any]] = [:]
            var counter = 0
            for document in documents {
                group.enter()
                document.reference.collection("monthly_views").getDocuments { querySnapshot, error in
                    defer { group.leave() }
                    guard let snapshot = querySnapshot, snapshot.isEmpty != true else {
                        counter += 1; return
                    }
                    
                    guard let item = try? document.data(as: Item.self) else {
                        return
                    }
                    
                    // item monthly documents
                    let monthlyDocuments = snapshot.documents
                    
                    let summaryMonthlyViews: [MonthlyViews] = monthlyDocuments.compactMap { documentSnapshot in
                        guard let monthly = try? documentSnapshot.data(as: MonthlyViews.self) else {
                            return nil
                        }
                        
                        return monthly
                    }
                    
                    resultDictionary[counter] = [
                        "item": item,
                        "views": summaryMonthlyViews
                    ]
                    
                    counter += 1
                }
            }
            
            group.notify(queue: .main) {
                if documents.count == counter {
                    completion(.success(resultDictionary))
                    return
                }
            }
        }
    }
    
//    func getSubscriptionsItems(userId: String, completion: @escaping (Result<[Item], Error>) -> ()) {
//        self.getSubscriptions(userId: userId) { result in
//            switch result {
//            case .success(let subscriptions):
//                var items: [Item] = []
//                var subscriptionsCount = subscriptions.count
//                let group = DispatchGroup()
//
//                for value in subscriptions {
//                    group.enter()
//                    self.itemsReference.whereField("brand_name", isEqualTo: value).getDocuments { snapshot, error in
//                        defer { group.leave() }
//                        guard let snapshot = snapshot else {
//                            return
//                        }
//
//                        let itemsInBrand = snapshot.documents.compactMap({ try? $0.data(as: Item.self) })
//                        items.append(contentsOf: itemsInBrand)
//                        subscriptionsCount -= 1
//                    }
//                }
//
//                group.notify(queue: .main) {
//                    completion(.success(items))
//                    return
//                }
//
//
//            case .failure(let error):
//                completion(.failure(error))
//            }
//        }
//    }
}

// MARK: - Errors
extension FeedService {
    private enum AdsServiceError: Error {
        case documentNotFound
        case addingItemError
    }
}
