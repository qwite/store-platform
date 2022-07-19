import UIKit
import FirebaseFirestore
import FirebaseFirestoreSwift

// MARK: - BrandServiceProtocol
protocol BrandServiceProtocol {
    func getBrandId(by userId: String, completion: @escaping (Result<String, Error>) -> ())
    func getBrandIdByName(brandName: String, completion: @escaping (Result<String, Error>) -> ())
    func createBrand(brand: Brand, userId: String, completion: @escaping (Error?) -> ())
    func uploadBrandImage(data: Data, completion: @escaping (Result<String, Error>) -> ())
    func uploadImages(with data: [Data], completion: @escaping (Result<[String], Error>) -> ())
    func fetchOrders(brandId: String, completion: @escaping (Result<[Order], Error>) -> ())
    func fetchItems(by userId: String, completion: @escaping (Result<[Item], Error>) -> ())
    func fetchMonthlyViews(by userId: String, month: String, completion: @escaping (Result<[MonthlyViews], Error>) -> ())
    func fetchMonthlyViewsItem(by itemId: String, month: String, completion: @escaping (Result<[MonthlyViews], Error>) -> ())
    func fetchSales(by userId: String, completion: @escaping (Result<[Item], Error>) -> ())
    func createNewAd(with item: Item, userId: String, completion: @escaping (Error?) -> ())
    func changeOrderStatus(orderId: String, status: Order.Status, completion: @escaping (Error?) -> ())
    func getBrandName(by userId: String, completion: @escaping (Result<String, Error>) -> ())
}

// MARK: - BrandServiceProtocol Implementation
class BrandService: BrandServiceProtocol {
    private let firebaseDb = Firestore.firestore()
    /// Users reference
    private var usersReference: CollectionReference {
        return firebaseDb.collection("users")
    }
    
    /// Brands reference
    private var brandsReference: CollectionReference {
        return firebaseDb.collection("brands")
    }
    
    /// Items reference
    private var itemsReference: CollectionReference {
        return firebaseDb.collection("items")
    }
    
    /// Orders reference
    private var ordersReference: CollectionReference {
        return firebaseDb.collection("orders")
    }
    
    func createBrand(brand: Brand, userId: String, completion: @escaping (Error?) -> ()) {
        // Adding document to 'brands' reference
        guard let document = try? brandsReference.addDocument(from: brand, completion: { error in
            guard error == nil else { completion(error!); return }
        }) else { completion(BrandServiceErrors.brandEncodingError); return }
        
        let brandDocumentId = document.documentID
        FirestoreService.sharedInstance.getUserDocumentSnapshot(by: userId) { result in
            switch result {
            case .success(let documentSnapshot):
                let brandCollection = documentSnapshot.reference.collection("brand")
                brandCollection.addDocument(data: ["brand_id": brandDocumentId]) { error in
                    guard error == nil else { completion(error); return }
                    
                    // Success action
                    completion(nil)
                }
                
            case .failure(let error):
                completion(error)
            }
        }
    }
    
    func uploadBrandImage(data: Data, completion: @escaping (Result<String, Error>) -> ()) {
        // Uploading image
        StorageService.sharedInstance.uploadImage(with: data, type: .brandLogo) { result in
            switch result {
            case .success(let url):
                completion(.success(url))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func getBrandIdByName(brandName: String, completion: @escaping (Result<String, Error>) -> ()) {
        brandsReference.whereField("brand_name", isEqualTo: brandName).getDocuments { querySnapshot, error in
            guard let snapshot = querySnapshot,
                  !snapshot.isEmpty,
                  let brandDocument = snapshot.documents.first else {
                return completion(.failure(BrandServiceErrors.documentsNotExist))
            }
            
            let documentId = brandDocument.documentID
            completion(.success(documentId))
        }
    }
    
    func fetchOrders(brandId: String, completion: @escaping (Result<[Order], Error>) -> ()) {
        let ordersCollection = brandsReference.document(brandId).collection("orders")
        ordersCollection.getDocuments { snapshot, error in
            guard let snapshot = snapshot, !snapshot.isEmpty else {
                completion(.failure(BrandServiceErrors.documentsNotExist)); return
            }
            
            // Getting orders identificators
            let ordersId: [String] = snapshot.documents.compactMap({ $0.get("order_id") as? String })
            var orders: [Order] = []
            for orderId in ordersId {
                // Getting order
                FirestoreService.sharedInstance.getOrderById(orderId: orderId) { result in
                    switch result {
                    case .success(let order):
                        orders.append(order)
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
                
                // Success action
                if orders.count == ordersId.count { completion(.success(orders)) }
            }
        }
    }
    
    func fetchItems(by userId: String, completion: @escaping (Result<[Item], Error>) -> ()) {
        self.getItemsId(by: userId) { result in
            switch result {
            case .success(let itemsId):
                var items: [Item] = []
                let group = DispatchGroup()
                
                for itemId in itemsId {
                    group.enter()
                    FirestoreService.sharedInstance.getItemByDocumentId(documentId: itemId) { result in
                        defer { group.leave() }
                        switch result {
                        case .success(let item):
                            items.append(item)
                        case .failure(let error):
                            completion(.failure(error))
                        }
                    }
                }
                
                // Success action
                group.notify(queue: .main) {
                    completion(.success(items))
                }
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func changeOrderStatus(orderId: String, status: Order.Status, completion: @escaping (Error?) -> ()) {
        let stringStatus = status.rawValue
        ordersReference.document(orderId).updateData(["status": stringStatus]) { error in
            guard error == nil else {
                completion(error!); return
            }
            
            // Success action
            completion(nil)
        }
    }
    
    func createNewAd(with item: Item, userId: String, completion: @escaping (Error?) -> ()) {
        self.getBrandId(by: userId) { result in
            switch result {
            case .success(let brandId):
                guard let document = try? self.itemsReference.addDocument(from: item) else {
                    completion(BrandServiceErrors.objectEncodingError); return
                }
                
                let newDocumentId = document.documentID
                let itemsCollection = self.brandsReference.document(brandId).collection("items")
                
                // Adding to brand new item identificator
                itemsCollection.addDocument(data: ["item_id": newDocumentId]) { error in
                    guard error == nil else { completion(error!); return }
                    
                    // Success action
                    completion(nil)
                }
            case .failure(let error):
                completion(error)
            }
        }
    }
    
    func getBrandName(by userId: String, completion: @escaping (Result<String, Error>) -> ()) {
        // Getting brand identificator
        self.getBrandId(by: userId) { result in
            switch result {
            case .success(let brandId):
                self.brandsReference.document(brandId).getDocument { snapshot, error in
                    guard let snapshot = snapshot else {
                        completion(.failure(BrandServiceErrors.documentsNotExist)); return
                    }
                    
                    guard let brandNameField = snapshot.get("brand_name") as? String else {
                        completion(.failure(BrandServiceErrors.fieldEncodingError)); return
                    }
                    
                    // Success action
                    completion(.success(brandNameField))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func fetchMonthlyViews(by userId: String, month: String, completion: @escaping (Result<[MonthlyViews], Error>) -> ()) {
        self.getBrandId(by: userId) { result in
            switch result {
            case .success(let brandId):
                self.getItemsId(by: brandId) { result in
                    switch result {
                    case .success(let itemsId):
                        var monthlyViews: [MonthlyViews] = []
                        let group = DispatchGroup()
                        
                        for item in itemsId {
                            group.enter()
                            self.fetchMonthlyViewsItem(by: item, month: month) { result in
                                defer { group.leave() }
                                switch result {
                                case .success(let views):
                                    monthlyViews.append(contentsOf: views)
                                case .failure(let error):
                                    completion(.failure(error))
                                }
                            }
                        }
                        
                        // Success action
                        group.notify(queue: .main) {
                            completion(.success(monthlyViews))
                        }
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func fetchMonthlyViewsItem(by itemId: String, month: String, completion: @escaping (Result<[MonthlyViews], Error>) -> ()) {
        var views: [MonthlyViews] = []
        let monthlyCollection = itemsReference.document(itemId).collection("monthly_views")
        monthlyCollection.whereField("month", isEqualTo: month).getDocuments { snapshot, error in
            guard let snapshot = snapshot, !snapshot.isEmpty else {
                completion(.failure(error!)); return
            }
            
            let monthlyViews = snapshot.documents.compactMap({ try? $0.data(as: MonthlyViews.self) })
            views.append(contentsOf: monthlyViews)
            // Success action
            completion(.success(views))
        }
    }
    
    func fetchSales(by userId: String, completion: @escaping (Result<[Item], Error>) -> ()) {
        // Getting brand identificator
        self.getBrandId(by: userId) { result in
            switch result {
            case .success(let brandId):
                let ordersCollection = self.brandsReference.document(brandId).collection("orders")
                ordersCollection.getDocuments { snapshot, error in
                    guard let snapshot = snapshot, !snapshot.isEmpty else {
                        completion(.failure(BrandServiceErrors.documentsNotExist)); return
                    }
                    
                    let itemsId = snapshot.documents.compactMap({ $0.get("item_id") as? String })
                    var items: [Item] = []
                    let group = DispatchGroup()
                    
                    for item in itemsId {
                        group.enter()
                        FirestoreService.sharedInstance.getItemByDocumentId(documentId: item) { result in
                            defer { group.leave() }
                            switch result {
                            case .success(let item):
                                items.append(item)
                            case .failure(let error):
                                completion(.failure(error))
                            }
                        }
                    }
                    
                    group.notify(queue: .main) {
                        completion(.success(items))
                    }
                }
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func uploadImages(with data: [Data], completion: @escaping (Result<[String], Error>) -> ()) {
        StorageService.sharedInstance.uploadItemImages(with: data) { result in
            switch result {
            case .success(let urls):
                // Success action
                completion(.success(urls))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func getBrandId(by userId: String, completion: @escaping (Result<String, Error>) -> ()) {
        FirestoreService.sharedInstance.getUserDocumentSnapshot(by: userId) { result in
            switch result {
            case .success(let document):
                let brandCollection = document.reference.collection("brand")
                brandCollection.getDocuments { snapshot, error in
                    guard let snapshot = snapshot,
                          let firstDoc = snapshot.documents.first,
                          !snapshot.isEmpty else {
                        completion(.failure(BrandServiceErrors.documentsNotExist)); return
                    }
                    
                    guard let brandId = firstDoc.get("brand_id") as? String else {
                        completion(.failure(BrandServiceErrors.fieldEncodingError)); return
                    }
                    
                    // Success action
                    completion(.success(brandId))
                }
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

// MARK: - Private helpers
extension BrandService {
    private func getItemsId(by userId: String, completion: @escaping (Result<[String], Error>) -> ()) {
        // Getting brand identificator
        self.getBrandId(by: userId) { result in
            switch result {
            case .success(let brandId):
                let itemsCollection = self.brandsReference.document(brandId).collection("items")
                itemsCollection.getDocuments { snapshot, error in
                    guard let snapshot = snapshot, !snapshot.isEmpty else {
                        completion(.failure(BrandServiceErrors.documentsNotExist)); return
                    }
                    
                    let itemsId: [String] = snapshot.documents.compactMap({ $0.get("item_id") as? String })
                    
                    // Success action
                    completion(.success(itemsId))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

extension BrandService {
    private enum BrandServiceErrors: Error {
        case brandEncodingError
        case documentsNotExist
        case fieldEncodingError
        case objectEncodingError
    }
}
