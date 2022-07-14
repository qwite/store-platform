import UIKit
import FirebaseFirestore
import FirebaseAuth
import FirebaseFirestoreSwift

// MARK: - Firestore Shared Service
class FirestoreService {
    static let sharedInstance = FirestoreService()
    private let firebaseDb = Firestore.firestore()
    
    /// Users reference
    private var usersReference: CollectionReference {
        return firebaseDb.collection("users")
    }
    
    /// Items reference
    private var itemsReference: CollectionReference {
        return firebaseDb.collection("items")
    }
    
    /// Brands reference
    private var brandsReference: CollectionReference {
        return firebaseDb.collection("brands")
    }
    
    /// Orders reference
    private var ordersReference: CollectionReference {
        return firebaseDb.collection("orders")
    }
    
    /// Orders reference
    private var reviewsReference: CollectionReference {
        return firebaseDb.collection("reviews")
    }
}

// MARK: - User Public methods
extension FirestoreService {
    
    /// Get user document snapshot. Returns QueryDocumentSnapshot
    /// This method required for prevent code duplicates
    func getUserDocumentSnapshot(by id: String, completion: @escaping (Result<QueryDocumentSnapshot, Error>) -> ()) {
        usersReference.whereField("id", isEqualTo: id).getDocuments { snapshot, error in
            guard let snapshot = snapshot,
                  !snapshot.isEmpty else {
                completion(.failure(FirestoreServiceError.userIdNotExist)); return
            }
            
            guard let document = snapshot.documents.first else {
                completion(.failure(FirestoreServiceError.documentNotFound)); return
            }
            
            completion(.success(document))
        }
    }
    
    /// Get user data by user identificator. Returns UserData
    func fetchUserData(by id: String, completion: @escaping (Result<UserData, Error>) -> ()) {
        self.getUserDocumentSnapshot(by: id) { result in
            switch result {
            case .success(let document):
                guard let userInfo = try? document.data(as: UserData.self) else {
                    completion(.failure(FirestoreServiceError.userDecodingError)); return
                }
                
                completion(.success(userInfo))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    /// Adding user info for user. Returns UserData
    func saveUserData(customUser: UserData, completion: @escaping (Result<UserData, Error>) -> ()) {
        guard let _ = try? usersReference.addDocument(from: customUser, completion: { error in
            guard error == nil else { completion(.failure(error!)); return }
        }) else {
            return completion(.failure(FirestoreServiceError.userEncodingError))
        }
        
        completion(.success(customUser))
    }
    
    /// Update user data  by user identificator. Returns Error in case of an error
    func updateUserData(by id: String, data: UserDetails, completion: @escaping (Error?) -> ()) {
        self.getUserDocumentSnapshot(by: id) { result in
            switch result {
            case .success(let document):
                let encoder = Firestore.Encoder()
                guard let dictData = try? encoder.encode(data) else {
                    completion(FirestoreServiceError.encodingError); return
                }
                
                // "Details" map
                self.usersReference.document(document.documentID).updateData(["details": dictData]) { error in
                    guard error == nil else { completion(error!); return }
                    
                    completion(nil)
                }
                
            case .failure(let error):
                completion(error); return
            }
        }
    }
    
    /// Adding to collection 'favorites' item. Returns Error in case of an error
    func addFavoriteItem(userId: String, itemId: String, completion: @escaping (Error?) -> ()) {
        self.getUserDocumentSnapshot(by: userId) { result in
            switch result {
            case .success(let document):
                let favoritesCollection = document.reference.collection("favorites")
                // Check if item already exist in 'favorites' user collection
                favoritesCollection.whereField("item_id", isEqualTo: itemId).getDocuments { snapshot, error in
                    guard let snapshot = snapshot, snapshot.documents.first == nil else {
                        completion(FirestoreServiceError.itemAlreadyExist); return
                    }
                    
                    favoritesCollection.addDocument(data: ["item_id": itemId]) { error in
                        guard error == nil else { completion(error!); return }
                        completion(nil)
                    }
                }
                
            case .failure(_):
                completion(FirestoreServiceError.documentNotFound)
            }
        }
    }
}

// MARK: - Item/Ads Public methods
extension FirestoreService {
    
    /// done
    /// Creating ad with item. Returns documentId
    func createAd(item: Item, completion: @escaping (Result<String, Error>) -> ()) {
        let documentItemId = try? itemsReference.addDocument(from: item, completion: { error in
            guard error == nil else {
                completion(.failure(error!)); return
            }
        }).documentID
        
        guard let documentItemId = documentItemId else {
            completion(.failure(FirestoreServiceError.itemAddError)); return
        }
        
        completion(.success(documentItemId))
    }
    
    // TODO: refactor
//    func createOrder(userId: String, item: CartItem, date: String, completion: @escaping (Error?) -> ()) {
//        self.fetchUserData(by: userId) { result in
//            switch result {
//            case .success(let userData):
//                guard let details = userData.details,
//                      let city = details.city,
//                      let street = details.street,
//                      let house = details.house,
//                      let apartment = details.apartment,
//                      let phoneNumber = details.phone,
//                      let lastName = userData.lastName,
//                      let firstName = userData.firstName else { return }
//                let shippingAddress = "г. \(city), ул. \(street), д. \(house), кв. \(apartment)"
//                let userFullName = "\(lastName) \(firstName)"
//                
//                self.getBrandIdByName(brandName: item.item.brandName) { result in
//                    switch result {
//                    case .success(let brandId):
//                        
//                        let order = Order(id: nil, userShippingAddress: shippingAddress,
//                                          userPhoneNumber: phoneNumber, userFullName: userFullName,
//                                          brandId: brandId, item: item,
//                                          status: Order.Status.process.rawValue, date: date)
//                        
//                        guard let order = try? self.ordersReference.addDocument(from: order, completion: { error in
//                            guard error == nil else { completion(FirestoreServiceError.brandDecodingError); return }
//                        }) else { completion(FirestoreServiceError.brandDecodingError); return }
//                        
//                        
//                        // data for adding to user and brand
//                        let data: [String: Any] = [
//                            "order_id": order.documentID,
//                            "item_id": item.itemId
//                        ]
//                        
//                        // adding order to user
//                        self.usersReference.whereField("id", isEqualTo: userId).getDocuments { querySnapshot, error in
//                            guard let snapshot = querySnapshot,
//                                  snapshot.isEmpty != true,
//                                  let userDocument = snapshot.documents.first else { completion(FirestoreServiceError.documentNotFound); return }
//                            
//                            userDocument.reference.collection("orders").addDocument(data: data) { error in
//                                guard error == nil else { completion(error!); return }
//                            }
//                        }
//                        
//                        // adding order to brand
//                        
//                        self.brandsReference.document(brandId).collection("orders").addDocument(data: data) { error in
//                            guard error == nil else { completion(error!); return}
//                        }
//                        
//                        // remove item from cart
//                        self.removeItemFromCart(userId: userId, selectedItem: item) { error in
//                            guard error == nil else { completion(error!); return }
//                            
//                            completion(nil)
//                        }
//                    case .failure(let error):
//                        completion(error)
//                    }
//                }
//            case .failure(let error):
//                completion(error)
//            }
//        }
//    }
    
    func changeOrderStatus(orderId: String, status: Order.Status, completion: @escaping (Error?) -> ()) {
        let stringStatus = status.rawValue
        ordersReference.document(orderId).updateData(["status": stringStatus]) { error in
            guard error == nil else {
                completion(error!); return
            }
            
            completion(nil)
        }
    }
    
    /// done
    func getPopularItems(completion: @escaping (Result<[Int: [String: Any]], Error>) -> ()) {
        itemsReference.getDocuments { querySnapshot, error in
            guard let snapshot = querySnapshot,
                  !snapshot.isEmpty else {
                return completion(.failure(FirestoreServiceError.documentNotFound))
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
            
            // get items where collection monthly_views not empty
            // sort items by views
            // return these items
            
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
    
    func putItemIdInBrand(brandId: String, itemId: String, completion: @escaping (Error?) -> ()) {
        brandsReference.document(brandId).collection("items").addDocument(data: ["item_id": itemId]) { error in
            guard error == nil else {
                completion(error!); return
            }
            
            completion(nil)
        }
    }
    
    func getUserOrders(userId: String, completion: @escaping (Result<[Order], Error>) -> ()) {
        usersReference.whereField("id", isEqualTo: userId).getDocuments { querySnapshot, error in
            guard let snapshot = querySnapshot,
                  snapshot.isEmpty != true,
                  let userDocument = snapshot.documents.first else {
                completion(.failure(FirestoreServiceError.documentNotFound)); return
            }
            
            userDocument.reference.collection("orders").getDocuments { querySnapshot, error in
                guard let snapshot = querySnapshot,
                      snapshot.isEmpty != true else {
                    completion(.failure(FirestoreServiceError.documentNotFound)); return
                }
                
                let ordersId: [String] = snapshot.documents.compactMap({ $0.get("order_id") as? String })
                print(ordersId)
                var orders: [Order] = []
                var counter = 0
                for id in ordersId {
                    self.getOrderById(orderId: id) { result in
                        switch result {
                        case .success(let order):
                            orders.append(order)
                            counter += 1

                        case .failure(let error):
                            completion(.failure(error))
                        }
                        
                        if counter == ordersId.count {
                            completion(.success(orders))
                        }
                    }
                }
            }
        }
    }
    
    func getBrandOrders(brandId: String, completion: @escaping (Result<[Order], Error>) -> ()) {
        brandsReference.document(brandId).collection("orders").getDocuments { querySnapshot, error in
            guard let snapshot = querySnapshot,
                  snapshot.isEmpty != true else {
                completion(.failure(FirestoreServiceError.documentNotFound)); return
            }
            
            let ordersId: [String] = snapshot.documents.compactMap({ $0.get("order_id") as? String })
            var orders: [Order] = []
            var counter = 0
            for id in ordersId {
                self.getOrderById(orderId: id) { result in
                    switch result {
                    case .success(let order):
                        orders.append(order)
                        counter += 1

                    case .failure(let error):
                        completion(.failure(error))
                    }
                    
                    if counter == ordersId.count {
                        completion(.success(orders))
                    }
                }
            }
        }
    }
    
    func getOrderById(orderId: String, completion: @escaping (Result<Order, Error>) -> ()) {
        ordersReference.document(orderId).getDocument { documentSnapshot, error in
            guard let snapshot = documentSnapshot else { completion(.failure(error!)); return }
            
            guard let order = try? snapshot.data(as: Order.self) else { fatalError() }
            completion(.success(order))
        }
    }

    func getBrandName(brandId: String, completion: @escaping (Result<String, Error>) -> ()) {
        brandsReference.document(brandId).getDocument { documentSnapshot, error in
            guard let documentSnapshot = documentSnapshot else {
                return completion(.failure(error!))
            }
            
            guard let brandName = documentSnapshot.get("brand_name") as? String else {
                // TODO: field not found
                return completion(.failure(FirestoreServiceError.documentNotFound))
            }
            
            completion(.success(brandName))
        }
    }
            
    func getItemByDocumentId(documentId: String, completion: @escaping (Result<Item, Error>) -> ()) {
        itemsReference.document(documentId).getDocument { documentSnapshot, error in
            guard let documentSnapshot = documentSnapshot else {
                return debugPrint("document not found")
            }
            
            guard let item = try? documentSnapshot.data(as: Item.self) else {
                return completion(.failure(FirestoreServiceError.itemDecodingError))
            }
            
            completion(.success(item))
        }
    }
        
    func removeFavoriteItem(userId: String, itemId: String, completion: @escaping (Result<String, Error>) -> ()) {
        usersReference.whereField("id", isEqualTo: userId).getDocuments { snapshot, error in
            guard let snapshot = snapshot else {
                return debugPrint("\(error!)")
            }
            
            guard let documentReference = snapshot.documents.first?.reference else {
                return debugPrint("reference not found")
            }
            
            
            debugPrint(itemId)
            documentReference.collection("favorites").whereField("item_id", isEqualTo: itemId).getDocuments { snapshot, error in
                guard let snapshot = snapshot else {
                    return debugPrint("\(error!)")
                }
                
                guard let document = snapshot.documents.first else {
                    fatalError("document does not exist")
                }
                
                documentReference.collection("favorites").document(document.documentID).delete()
                completion(.success(""))
            }
        }
    }
    
    
    func createBrand(userId: String, brand: Brand, completion: @escaping (Result<[String: String], Error>) -> ()) {
        guard let brandDocumentId = try? brandsReference.addDocument(from: brand, completion: { error in
            guard error == nil else {
                return completion(.failure(FirestoreServiceError.brandCreatingError))
            }
        }).documentID else {
            return completion(.failure(FirestoreServiceError.brandCreatingError))
        }
        
        self.usersReference.whereField("id", isEqualTo: userId).getDocuments { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                return completion(.failure(error!))
            }
            
            guard let userReference = snapshot.documents.first?.reference else {
                return completion(.failure(FirestoreServiceError.userDocumentNotFound))
            }
            
            userReference.collection("brand").addDocument(data: ["brand_id": brandDocumentId]) { error in
                guard error == nil else {
                    return completion(.failure(error!))
                }
                
                let dict: [String: String] = ["brand_id": brandDocumentId, "brand_name": brand.brandName.lowercased()]
                completion(.success(dict))
            }
        }
    }
    
    func getSellerStatus(userId: String, completion: @escaping (Result<Bool, Error>) -> ()) {
        usersReference.whereField("id", isEqualTo: userId).getDocuments { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                return completion(.failure(error!))
            }
            
            guard let userReference = snapshot.documents.last?.reference else {
                return completion(.failure(FirestoreServiceError.userDocumentNotFound))
            }
            
            userReference.collection("brand").getDocuments { querySnapshot, error in
                guard let snapshot = querySnapshot else {
                    return completion(.failure(error!))
                }
                
                guard snapshot.isEmpty == false,
                      let brandId = try? snapshot.documents.first?.get("brand_id")  else {
                    return completion(.failure(FirestoreServiceError.brandNotExist))
                }
                
                completion(.success(true))
            }
        }
    }
    
    func getBrandId(userId: String, completion: @escaping (Result<String, Error>) -> ()) {
        usersReference.whereField("id", isEqualTo: userId).getDocuments { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                return completion(.failure(error!))
            }
            
            guard let userReference = snapshot.documents.first?.reference else {
                return completion(.failure(FirestoreServiceError.userDocumentNotFound))
            }
            
            userReference.collection("brand").getDocuments { querySnapshot, error in
                guard let snapshot = querySnapshot else {
                    return completion(.failure(FirestoreServiceError.documentNotFound))
                }
                
                guard let brandId = snapshot.documents.first?.get("brand_id") as? String else {
                    fatalError()
                }
                
                completion(.success(brandId))
            }
        }
    }
    
    func getBrandIdByName(brandName: String, completion: @escaping (Result<String, Error>) -> ()) {
        brandsReference.whereField("brand_name", isEqualTo: brandName).getDocuments { querySnapshot, error in
            guard let snapshot = querySnapshot,
                  snapshot.isEmpty == false,
                  let brandDocument = snapshot.documents.first else {
                return completion(.failure(FirestoreServiceError.documentNotFound))
            }
            
            let documentId = brandDocument.documentID
            completion(.success(documentId))
        }
    }
    
    func getItemIdsFromBrand(brandId: String, completion: @escaping(Result<[String], Error>) -> ()) {
        brandsReference.document(brandId).collection("items").getDocuments { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                fatalError()
            }
            
            guard snapshot.isEmpty != true else {
                return completion(.failure(FirestoreServiceError.documentNotFound))
            }
            
            let documents = snapshot.documents
            var items: [String] = []
            for document in documents {
                guard let value = document.get("item_id") as? String else {
                    return debugPrint("document string decoding error")
                }
                
                items.append(value)
                if items.count == documents.count {
                    completion(.success(items))
                }
            }
        }
    }
    
    func getItemIdsFromBrandSales(brandId: String, completion: @escaping (Result<[String], Error>) -> ()) {
        // get item ids
        brandsReference.document(brandId).collection("orders").getDocuments { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                return completion(.failure(error!))
            }
            
            guard snapshot.isEmpty != true else {
                return completion(.failure(FirestoreServiceError.documentNotFound))
            }
            
            let documents = snapshot.documents
            var resultIds: [String] = []
            for document in documents {
                let data = document.get("item_id") as! String
                resultIds.append(data)
                
                if documents.count == resultIds.count {
                    completion(.success(resultIds))
                }
            }
        }
    }
    
    func getViewsAmountFromItem(itemId: String, completion: @escaping (Result<[MonthlyViews], Error>) -> ()) {
        var views: [MonthlyViews] = []
        let reference = itemsReference.document(itemId).collection("monthly_views")
        reference.whereField("month", isEqualTo: "Jun").getDocuments { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                return completion(.failure(error!))
            }
            
            guard snapshot.isEmpty != true else {
                return completion(.failure(FirestoreServiceError.documentNotFound))
            }
            
            let documents = snapshot.documents
            for document in documents {
                guard let data = try? document.data(as: MonthlyViews.self) else {
                    fatalError()
                }
                
                views.append(data)
                if views.count == documents.count {
                    completion(.success(views))
                }
            }
        }
    }
    
    func getViewsAmountFromItems(items: [String], completion: @escaping (Result<[MonthlyViews], Error>) -> ()) {
        var monthlyViews: [MonthlyViews] = []
        let group = DispatchGroup()
        
        for item in items {
            group.enter()
            let reference = itemsReference.document(item).collection("monthly_views")
            reference.whereField("month", isEqualTo: "Jun").getDocuments { querySnapshot, error in
                defer { group.leave() }
                guard let snapshot = querySnapshot else {
                    return completion(.failure(error!))
                }
                
                // return completion(.failure(FirestoreServiceError.viewsDocumentNotExist))
                guard snapshot.isEmpty != true else {
                    return
                }
                
                let documents = snapshot.documents
                for document in documents {
                    guard let data = try? document.data(as: MonthlyViews.self) else {
                        fatalError()
                    }
                    
                    monthlyViews.append(data)
                }
            }
        }
        
        group.notify(queue: .main) {
            if monthlyViews.count > 0 {
                completion(.success(monthlyViews))
            }
        }
    }
        
    func addReviewToItem(itemId: String, review: Review, completion: @escaping (Error?) -> ()) {
        guard let documentReference = try? reviewsReference.addDocument(from: review, completion: { error in
            guard error == nil else { completion(error!); return }
        }) else {
            completion(FirestoreServiceError.encodingError); return
        }
        
        let reviewId = documentReference.documentID
        
        itemsReference.document(itemId).collection("reviews").addDocument(data: ["review_id": reviewId]) { error in
            guard error == nil else { completion(error!); return }
            
            completion(nil)
        }
    }
        
    func addToSubscriptions(userId: String, brandId: String, brandName: String, completion: @escaping (Error?) -> ()) {
        usersReference.whereField("id", isEqualTo: userId).getDocuments { querySnapshot, error in
            guard let snapshot = querySnapshot,
                  snapshot.isEmpty != true else {
                return
            }
            
            guard let reference = snapshot.documents.first?.reference else { return }
            reference.collection("subscriptions").addDocument(data: ["brand_id": brandId, "brand_name": brandName]) { error in
                guard error == nil else { completion(error!); return }
                
                completion(nil)
            }
        }
    }
    
    func removeSubscription(userId: String, brandName: String, completion: @escaping (Error?) -> ()) {
        usersReference.whereField("id", isEqualTo: userId).getDocuments { querySnapshot, error in
            guard let snapshot = querySnapshot,
                  snapshot.isEmpty != true else {
                return
            }
            
            guard let reference = snapshot.documents.first?.reference else { return }
            reference.collection("subscriptions").whereField("brand_name", isEqualTo: brandName).getDocuments { querySnapshot, error in
                guard let querySnapshot = querySnapshot else {
                    return
                }
                
                guard let firstDocument = querySnapshot.documents.first?.reference else { fatalError() }
                let subscriptionDocumentId = firstDocument.documentID
                
                reference.collection("subscriptions").document(subscriptionDocumentId).delete { error in
                    guard error == nil else { completion(error!); return }
                    completion(nil)
                }
            }
        }
    }
    
}

// MARK: - Firestore Service Errors
extension FirestoreService {
    private enum FirestoreServiceError: Error {
        case documentNotFound
        case itemPhotoNotExist
        case itemAddError
        case itemEncodingError
        case itemDecodingError
        case itemAlreadyExist
        case userIdNotExist
        case userDocumentNotFound
        case userEncodingError
        case userDecodingError
        case brandCreatingError
        case brandDecodingError
        case brandNotExist
        case encodingError
        case decodingError
    }
}
