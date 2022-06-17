import UIKit
import FirebaseFirestore
import FirebaseAuth
import FirebaseFirestoreSwift

// MARK: - Singleton Firestore Service
class FirestoreService {
    static let sharedInstance = FirestoreService()
    let firebaseDb = Firestore.firestore()
    
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
    
    /// Get user data by identificator and returns this
    func getUserInfo(by id: String, completion: @escaping (Result<CustomUser, Error>) -> ()) {
        usersReference.whereField("id", isEqualTo: id).getDocuments { snapshot, error in
            guard let snapshot = snapshot else {
                return completion(.failure(FirestoreServiceError.userIdNotExist))
            }
            
            let document = snapshot.documents.first
            guard let document = document else {
                return completion(.failure(FirestoreServiceError.documentNotFound))
            }
            
            guard let userInfo = try? document.data(as: CustomUser.self) else {
                return completion(.failure(FirestoreServiceError.userDecodingError))
            }
            
            completion(.success(userInfo))
        }
    }
    
    /// Creating new ad returns item id
    //    func createAd(item: Item, completion: @escaping (Result<String, Error>) -> ()) {
    //        do {
    //            let _ = try itemsReference.addDocument(from: item, completion: { error in
    //                guard error == nil,
    //                      let id = item.id else {
    //                    return completion(.failure(error!))
    //                }
    //
    //                completion(.success(id))
    //            })
    //        } catch {
    //            completion(.failure(error))
    //        }
    //    }
    
    func createAd(item: Item, completion: @escaping (Result<String, Error>) -> ()) {
        let documentItemId = try? itemsReference.addDocument(from: item, completion: { error in
            guard error == nil else { return completion(.failure(error!)) }
        }).documentID
        
        guard let documentItemId = documentItemId else {
            return completion(.failure(FirestoreServiceError.itemAddError))
        }
        
        completion(.success(documentItemId))
    }
    
    /// Parse all ads and returns this
    func getAllItems(sorted items: Item.Sorting? = nil, completion: @escaping (Result<[Item], Error>) -> ()) {
        itemsReference.getDocuments { snapshot, error in
            guard let snapshot = snapshot else {
                return completion(.failure(error!))
            }
            
            let documents = snapshot.documents
            let resultItems = documents.compactMap { querySnapshot in
                return try? querySnapshot.data(as: Item.self)
            }
            
            guard let sortedItems = items else {
                completion(.success(resultItems)); return
            }
            
            
            // sorting
            
            let resultSortedItems: [Item] = resultItems.sorted { firstItem, secondItem in
                guard let firstPrice = firstItem.sizes?.first?.price,
                      let secondPrice = secondItem.sizes?.first?.price else {
                    completion(.failure(FirestoreServiceError.documentNotFound)); fatalError()
                }
                
                switch sortedItems {
                case .byIncreasePrice:
                    return secondPrice > firstPrice
                case .byDecreasePrice:
                    return secondPrice < firstPrice
                }
            }
            
            completion(.success(resultSortedItems))
        }
    }
    
    func getPopularItems(completion: @escaping (Result<[Int: [String: Any]], Error>) -> ()) {
        itemsReference.getDocuments { querySnapshot, error in
            guard let snapshot = querySnapshot, snapshot.isEmpty != true else {
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
    
    func addItemToBrand(brandId: String, itemId: String, completion: @escaping (Result<String, Error>) -> ()) {
        brandsReference.document(brandId).collection("items").addDocument(data: ["item_id": itemId]) { error in
            guard error == nil else {
                return completion(.failure(error!))
            }
            
            completion(.success("item added to brand"))
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
    
    func getItemsByCategory(category: String, completion: @escaping (Result<[Item], Error>) -> ()) {
        itemsReference.whereField("category", isEqualTo: category).getDocuments { querySnapshot, error in
            guard let snapshot = querySnapshot, !snapshot.isEmpty else {
                completion(.failure(FirestoreServiceError.documentNotFound)); return
            }
            
            let documents: [Item] = snapshot.documents.compactMap { snap in
                guard let item = try? snap.data(as: Item.self) else { return nil }
                return item
            }
            
            completion(.success(documents))
        }
    }
    
    func getItemsByBrand(brand: String, completion: @escaping (Result<[Item], Error>) -> ()) {
        let brandLowerCased = brand.lowercased()
        itemsReference.whereField("brand_name", isEqualTo: brandLowerCased).getDocuments { querySnapshot, error in
            guard let snapshot = querySnapshot, !snapshot.isEmpty else {
                return
            }
            
            let documents: [Item] = snapshot.documents.compactMap { snap in
                guard let item = try? snap.data(as: Item.self) else { return nil }
                return item
            }
            
            completion(.success(documents))
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
    
    /// Adding user info for user and returns this
    func saveUserInfo(customUser: CustomUser, completion: @escaping (Result<CustomUser, Error>) -> ()) {
        guard let _ = try? usersReference.addDocument(from: customUser) else {
            return completion(.failure(FirestoreServiceError.userEncodingError))
        }
        
        completion(.success(customUser))
    }
    
    func addFavoriteItem(userId: String, itemId: String, completion: @escaping (Result<String, Error>) -> ()) {
        usersReference.whereField("id", isEqualTo: userId).getDocuments { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                return completion(.failure(error!))
            }
            
            guard let documentReference = snapshot.documents.first?.reference else {
                return debugPrint("reference not found")
            }
            
            // check if itemid already exist
            documentReference.collection("favorites").whereField("item_id", isEqualTo: itemId).getDocuments { snapshot, error in
                guard let snapshot = snapshot else {
                    return debugPrint("some error")
                }
                
                guard snapshot.documents.first == nil else {
                    return completion(.failure(FirestoreServiceError.itemAlreadyExist))
                }
                
                documentReference.collection("favorites").addDocument(data: ["item_id": itemId])
                completion(.success(""))
            }
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
    
    func addItemToCart(userId: String, selectedItem: CartItem, completion: @escaping (Result<String, Error>) -> ()) {
        usersReference.whereField("id", isEqualTo: userId).getDocuments { snapshot, error in
            guard let snapshot = snapshot else {
                return completion(.failure(error!))
            }
            
            guard let userDocument = snapshot.documents.first else {
                return completion(.failure(FirestoreServiceError.userDocumentNotFound))
            }
            
            let documentReference = userDocument.reference
            guard let doc = try? documentReference.collection("cart").addDocument(from: selectedItem) else {
                return completion(.failure(FirestoreServiceError.itemEncodingError))
            }
            
            completion(.success("item added"))
        }
    }
    
    func removeItemFromCart(userId: String, selectedItem: CartItem, completion: @escaping ((Error?) -> ())) {
        usersReference.whereField("id", isEqualTo: userId).getDocuments { snapshot, error in
            guard let snapshot = snapshot, snapshot.isEmpty != true else {
                completion(error!); return
            }
            
            guard let userDocument = snapshot.documents.first else {
                completion(FirestoreServiceError.userDocumentNotFound); return
            }
            
            let documentReference = userDocument.reference
            documentReference.collection("cart").whereField("item_id", isEqualTo: selectedItem.itemId).getDocuments { querySnapshot, error in
                guard let snapshot = querySnapshot, snapshot.isEmpty != true else {
                    completion(FirestoreServiceError.documentNotFound); return
                }
                
                guard let document = snapshot.documents.first else {
                    return
                }
                
                documentReference.collection("cart").document(document.documentID).delete { error in
                    guard error == nil else {
                        completion(error!); return
                    }
                    
                    completion(nil)
                }
            }
        }
    }
    
    func getItemsFromCart(userId: String, completion: @escaping (Result<[CartItem], Error>) -> ()) {
        usersReference.whereField("id", isEqualTo: userId).getDocuments { snapshot, error in
            guard let snapshot = snapshot else {
                return completion(.failure(error!))
            }
            
            guard let userDocument = snapshot.documents.last else {
                return print("document not found")
            }
            
            let documentReference = userDocument.reference
            let cartReference = documentReference.collection("cart")
            cartReference.getDocuments { snapshot, error in
                guard let snapshot = snapshot else {
                    return completion(.failure(error!))
                }
                
                let document = snapshot.documents
                let items = document.compactMap { querySnapshot in
                    return try? querySnapshot.data(as: CartItem.self)
                }
                
                completion(.success(items))
            }
        }
    }
    
    func getFavoritesIds(by userid: String, completion: @escaping (Result<[String], Error>) -> ()) {
        usersReference.whereField("id", isEqualTo: userid).getDocuments { snapshot, error in
            guard let snapshot = snapshot else {
                return completion(.failure(error!))
            }
            
            guard let userDocument = snapshot.documents.last else {
                return print("document not found")
            }
            
            let documentReference = userDocument.reference
            
            // go to subcollection
            let favorites = documentReference.collection("favorites")
            
            favorites.getDocuments { snap, error in
                var ids: [String] = []
                guard let snap = snap else {
                    return print(error!)
                }
                
                let documents = snap.documents
                for document in documents {
                    guard let value = document.get("item_id") as? String else {
                        return debugPrint("document string decoding error")
                    }
                    
                    ids.append(value)
                    if ids.count == documents.count {
                        completion(.success(ids))
                    }
                }
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
    
    func increaseItemViewsCounter(month: String, day: Int, itemId: String, completion: @escaping (Result<String, Error>) -> ()) {
        let reference = itemsReference.document(itemId).collection("monthly_views")
        reference.whereField("month", isEqualTo: month).whereField("day", isEqualTo: day).getDocuments { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                return completion(.failure(error!))
            }
            
            if let documentReference = snapshot.documents.first?.reference  {
                documentReference.updateData(["amount": FieldValue.increment(Int64(1))])
                completion(.success("updated"))
            } else {
                let monthly = MonthlyViews(month: month, day: day, amount: 1)
                try? reference.addDocument(from: monthly, completion: { error in
                    guard error == nil else {
                        return completion(.failure(error!))
                    }
                    
                    completion(.success("added"))
                })
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
        brandsReference.document(brandId).collection("sales").getDocuments { querySnapshot, error in
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
    
    func getUserFullName(userId: String, completion: @escaping (Result<[String: String], Error>) -> ()) {
        usersReference.whereField("id", isEqualTo: userId).getDocuments { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                return completion(.failure(error!))
            }
            
            guard snapshot.isEmpty != true,
                  let firstUserDocument = snapshot.documents.first else {
                return completion(.failure(FirestoreServiceError.userDocumentNotFound))
            }
            
            var fullNameDictionary: [String: String] = [:]
            
            fullNameDictionary["firstName"] = firstUserDocument.get("firstName") as? String
            fullNameDictionary["lastName"] = firstUserDocument.get("lastName") as? String
            
            completion(.success(fullNameDictionary))
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
        case viewsDocumentNotExist
    }
}
