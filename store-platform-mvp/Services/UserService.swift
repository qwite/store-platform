import UIKit
import FirebaseFirestore
import FirebaseAuth
import FirebaseFirestoreSwift

// MARK: - UserService Protocol
protocol UserServiceProtocol {
    func addReviewItem(by itemId: String, review: Review, completion: @escaping (Error?) -> ())
    func getUserDocumentSnapshot(by id: String, completion: @escaping (Result<QueryDocumentSnapshot, Error>) -> ())
    func fetchUserSubscriptions(userId: String, completion: @escaping (Result<[String], Error>) -> ())
    func removeSubscription(userId: String, brandName: String, completion: @escaping (Error?) -> ())
    func fetchUserData(by id: String, completion: @escaping (Result<UserData, Error>) -> ())
    func fetchUserOrders(by userId: String, completion: @escaping (Result<[Order], Error>) -> ())
    func updateUserData(by id: String, data: UserDetails, completion: @escaping (Error?) -> ())
    func saveUserData(userData: UserData, completion: @escaping (Error?) -> ())
    func logout(completion: @escaping (Error?) -> ())
}

// MARK: - UserService Implementation
class UserService: UserServiceProtocol {
    private let firebaseDb = Firestore.firestore()
    
    /// Users reference
    private var usersReference: CollectionReference {
        return firebaseDb.collection("users")
    }
    
    /// Orders reference
    private var reviewsReference: CollectionReference {
        return firebaseDb.collection("reviews")
    }
    
    /// Items reference
    private var itemsReference: CollectionReference {
        return firebaseDb.collection("items")
    }
    
    /// Get user document snapshot. Returns QueryDocumentSnapshot
    /// This method required for prevent code duplicates
    func getUserDocumentSnapshot(by id: String, completion: @escaping (Result<QueryDocumentSnapshot, Error>) -> ()) {
        usersReference.whereField("id", isEqualTo: id).getDocuments { snapshot, error in
            guard let snapshot = snapshot,
                  !snapshot.isEmpty else {
                completion(.failure(UserServiceErrors.documentNotFoundError)); return
            }
            
            guard let document = snapshot.documents.first else {
                completion(.failure(UserServiceErrors.documentNotFoundError)); return
            }
            
            // Success action
            completion(.success(document))
        }
    }
    
    /// Get user subscription list. Returns [String]
    func fetchUserSubscriptions(userId: String, completion: @escaping (Result<[String], Error>) -> ()) {
        self.getUserDocumentSnapshot(by: userId) { result in
            switch result {
            case .success(let document):
                let collection = document.reference.collection("subscriptions")
                
                collection.getDocuments { snapshot, error in
                    guard let snapshot = snapshot, !snapshot.isEmpty else {
                        completion(.failure(UserServiceErrors.documentNotFoundError)); return
                    }
                    
                    let list = snapshot.documents.compactMap({ $0.get("brand_name") as? String })
                    // Success action
                    completion(.success(list))
                }
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    /// Adding user info for user. Returns nil or Error
    func saveUserData(userData: UserData, completion: @escaping (Error?) -> ()) {
        guard let _ = try? usersReference.addDocument(from: userData, completion: { error in
            guard error == nil else {
                completion(error!); return
            }
            
            RealTimeService.sharedInstance.insertUser(with: userData) { error in
                guard error == nil else {
                    completion(error!); return
                }
                
                // Success action
                completion(nil)
            }
        }) else {
            completion(UserServiceErrors.objectEncodingError); return
        }
    }
    
    /// Get user data by user identificator. Returns UserData
    func fetchUserData(by id: String, completion: @escaping (Result<UserData, Error>) -> ()) {
        self.getUserDocumentSnapshot(by: id) { result in
            switch result {
            case .success(let document):
                guard let userInfo = try? document.data(as: UserData.self) else {
                    completion(.failure(UserServiceErrors.objectEncodingError)); return
                }
                
                completion(.success(userInfo))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    /// Update user data  by user identificator. Returns Error in case of an error
    func updateUserData(by id: String, data: UserDetails, completion: @escaping (Error?) -> ()) {
        self.getUserDocumentSnapshot(by: id) { result in
            switch result {
            case .success(let document):
                let encoder = Firestore.Encoder()
                guard let dictData = try? encoder.encode(data) else {
                    completion(UserServiceErrors.objectEncodingError); return
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
    
    func addReviewItem(by itemId: String, review: Review, completion: @escaping (Error?) -> ()) {
        guard let documentReference = try? reviewsReference.addDocument(from: review, completion: { error in
            guard error == nil else { completion(error!); return }
        }) else {
            completion(UserServiceErrors.objectEncodingError); return
        }
        
        let reviewId = documentReference.documentID
        let reviewsCollection = itemsReference.document(itemId).collection("reviews")
        reviewsCollection.addDocument(data: ["review_id": reviewId]) { error in
            guard error == nil else { completion(error!); return }
            
            completion(nil)
        }
    }
    
    func logout(completion: @escaping (Error?) -> ()) {
        AuthService.sharedInstance.logout { error in
            guard error == nil else { completion(error); return }
        }
        
        SettingsService.sharedInstance.resetUserData()
        completion(nil)
    }
    
    func fetchUserOrders(by userId: String, completion: @escaping (Result<[Order], Error>) -> ()) {
        self.getUserDocumentSnapshot(by: userId) { result in
            switch result {
            case .success(let document):
                let ordersCollection = document.reference.collection("orders")
                ordersCollection.getDocuments { snapshot, error in
                    guard let snapshot = snapshot, !snapshot.isEmpty else {
                        completion(.failure(UserServiceErrors.documentNotFoundError)); return
                    }
                    
                    let ordersId: [String] = snapshot.documents.compactMap({ $0.get("order_id") as? String })
                    var orders: [Order] = []
                    let group = DispatchGroup()
                    for id in ordersId {
                        group.enter()
                        FirestoreService.sharedInstance.getOrderById(orderId: id) { result in
                            defer { group.leave() }
                            switch result {
                            case .success(let order):
                                orders.append(order)
                            case .failure(let error):
                                completion(.failure(error))
                            }
                        }
                    }
                    
                    // Success action
                    group.notify(queue: .main) {
                        completion(.success(orders))
                    }

                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func removeSubscription(userId: String, brandName: String, completion: @escaping (Error?) -> ()) {
        self.getUserDocumentSnapshot(by: userId) { result in
            switch result {
            case .success(let document):
                let subscriptionsCollection = document.reference.collection("subscriptions")
                subscriptionsCollection.whereField("brand_name", isEqualTo: brandName).getDocuments { snapshot, error in
                    guard let snapshot = snapshot, !snapshot.isEmpty,
                          let firstDoc = snapshot.documents.first?.reference else {
                        completion(UserServiceErrors.documentNotFoundError); return
                    }
                    
                    let subscriptionsDocumentId = firstDoc.documentID
                    subscriptionsCollection.document(subscriptionsDocumentId).delete { error in
                        guard error == nil else {
                            completion(error!); return
                        }
                        
                        // Success action
                        completion(nil)
                    }
                }
            case .failure(let error):
                completion(error)
            }
        }
    }
}

// MARK: - UserService Errors
extension UserService {
    private enum UserServiceErrors: Error {
        case documentNotFoundError
        case favItemAlreadyExistsError
        case objectEncodingError
    }
}

