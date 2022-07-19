import UIKit
import FirebaseFirestore
import FirebaseAuth
import FirebaseFirestoreSwift

// MARK: - FeedServiceProtocol
protocol FeedServiceProtocol {
    func fetchAllItems(by sort: Item.Sorting?, completion: @escaping (Result<[Item], Error>) -> ())
    func fetchItemsByCategory(category: String, completion: @escaping (Result<[Item], Error>) -> ())
    func fetchItemsByBrandName(brand: String, completion: @escaping (Result<[Item], Error>) -> ())
    func addSubscription(userId: String, brandId: String, brandName: String, completion: @escaping (Error?) -> ())
    func fetchPopularItems(completion: @escaping (Result<[Int: [String: Any]], Error>) -> ())
    func fetchSubscriptionItems(subscriptionList: [String], completion: @escaping (Result<[Item], Error>) -> ())
    func fetchItemReviews(item: Item, completion: @escaping (Result<[Review], Error>) -> ())
    func fetchReview(by id: String, completion: @escaping (Result<Review, Error>) -> ())
    func increaseItemViews(item: Item, views: MonthlyViews, completion: @escaping (Error?) -> ())
}

// MARK: - FeedServiceProtocol Implementation
class FeedService: FeedServiceProtocol {
    private let firebaseDb = Firestore.firestore()
    
    /// Users reference
    private var usersReference: CollectionReference {
        return firebaseDb.collection("users")
    }
    
    /// Items reference
    private var itemsReference: CollectionReference {
        return firebaseDb.collection("items")
    }
    
    /// Reviews reference
    private var reviewsReference: CollectionReference {
        return firebaseDb.collection("reviews")
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
                completion(.failure(FeedServiceErrors.documentsNotExist)); return
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
                completion(.failure(FeedServiceErrors.documentsNotExist)); return
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
                return completion(.failure(FeedServiceErrors.documentsNotExist))
            }
            
            let group = DispatchGroup()
            
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
    
    func addSubscription(userId: String, brandId: String, brandName: String, completion: @escaping (Error?) -> ()) {
        usersReference.whereField("id", isEqualTo: userId).getDocuments { querySnapshot, error in
            guard let snapshot = querySnapshot,
                  !snapshot.isEmpty else {
                return
            }
            
            guard let reference = snapshot.documents.first?.reference else { return }
            reference.collection("subscriptions").addDocument(data: ["brand_id": brandId, "brand_name": brandName]) { error in
                guard error == nil else { completion(error!); return }
                
                completion(nil)
            }
        }
    }
    
    func fetchSubscriptionItems(subscriptionList: [String], completion: @escaping (Result<[Item], Error>) -> ()) {
        var items: [Item] = []
        var subscriptionCount = subscriptionList.count
        let group = DispatchGroup()
        
        for brand in subscriptionList {
            group.enter()
            itemsReference.whereField("brand_name", isEqualTo: brand).getDocuments { snapshot, error in
                defer { group.leave() }
                guard let snapshot = snapshot,
                      !snapshot.isEmpty else {
                    return
                }
                
                let itemsByBrand = snapshot.documents.compactMap({ try? $0.data(as: Item.self) })
                items.append(contentsOf: itemsByBrand)
                subscriptionCount -= 1
            }
        }
        
        group.notify(queue: .main) {
            completion(.success(items))
            return
        }
    }
    
    func fetchItemReviews(item: Item, completion: @escaping (Result<[Review], Error>) -> ()) {
        guard let itemId = item.id else { return }
        
        let reviewsCollection = itemsReference.document(itemId).collection("reviews")
        reviewsCollection.getDocuments { [weak self] snapshot, error in
            guard let snapshot = snapshot, !snapshot.isEmpty else {
                completion(.failure(FeedServiceErrors.documentsNotExist)); return
            }
            
            let reviewsId: [String] = snapshot.documents.compactMap({ $0.get("review_id") as? String })
            var reviews: [Review] = []
            for id in reviewsId {
                self?.fetchReview(by: id) { result in
                    switch result {
                    case .success(let review):
                        reviews.append(review)
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
                
                if reviews.count == reviewsId.count { completion(.success(reviews)) }
            }
        }
    }
    
    func fetchReview(by id: String, completion: @escaping (Result<Review, Error>) -> ()) {
        reviewsReference.document(id).getDocument { snapshot, error in
            guard let snapshot = snapshot else {
                completion(.failure(FeedServiceErrors.documentsNotExist)); return
            }
            
            guard let review = try? snapshot.data(as: Review.self) else {
                completion(.failure(FeedServiceErrors.encodingReviewError)); return
            }
            
            completion(.success(review))
        }
    }
    
    func increaseItemViews(item: Item, views: MonthlyViews, completion: @escaping (Error?) -> ()) {
        guard let itemId = item.id else { return }
        
        let monthlyCollection = itemsReference.document(itemId).collection("monthly_views")
        monthlyCollection.whereField("month", isEqualTo: views.month).whereField("day", isEqualTo: views.day).getDocuments { snapshot, error in
            guard let snapshot = snapshot else {
                completion(error!); return
            }
            
            // Checks if document already exists. If exists -> Increase value (1)
            if let document = snapshot.documents.first?.reference {
                let value = Int64(1)
                document.updateData(["amount": FieldValue.increment(value)]) { error in
                    guard error == nil else { completion(error!); return }
                }
                
                completion(nil)
            } else {
                
                // Creating a document in 'monthly' collection for item
                guard let _ = try? monthlyCollection.addDocument(from: views, completion: { error in
                    guard error == nil else { completion(error!); return }
                    
                    completion(nil)
                }) else { completion(FeedServiceErrors.encodingViewsError); return }
            }
        }
    }
}

// MARK: - Errors
extension FeedService {
    private enum FeedServiceErrors: Error {
        case documentsNotExist
        case addingItemError
        case encodingViewsError
        case encodingReviewError
    }
}
