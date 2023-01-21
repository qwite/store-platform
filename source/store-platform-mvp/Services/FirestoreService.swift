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
}

// MARK: - Item Public methods
extension FirestoreService {
    func getOrderById(orderId: String, completion: @escaping (Result<Order, Error>) -> ()) {
        ordersReference.document(orderId).getDocument { documentSnapshot, error in
            guard let snapshot = documentSnapshot else { completion(.failure(error!)); return }
            
            guard let order = try? snapshot.data(as: Order.self) else { fatalError() }
            completion(.success(order))
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
                
                guard !snapshot.isEmpty,
                      let brandId = try? snapshot.documents.first?.get("brand_id") else {
                    return completion(.failure(FirestoreServiceError.brandNotExist))
                }
                
                completion(.success(true))
            }
        }
    }
    
    func getBrandIdByName(brandName: String, completion: @escaping (Result<String, Error>) -> ()) {
        brandsReference.whereField("brand_name", isEqualTo: brandName).getDocuments { querySnapshot, error in
            guard let snapshot = querySnapshot,
                  snapshot.isEmpty == false,
                  let brandDocument = snapshot.documents.first else {
                completion(.failure(FirestoreServiceError.documentNotFound)); return
            }
            
            let documentId = brandDocument.documentID
            completion(.success(documentId))
        }
    }
    
    func getBrandName(brandId: String, completion: @escaping (Result<String, Error>) -> ()) {
           brandsReference.document(brandId).getDocument { documentSnapshot, error in
               guard let documentSnapshot = documentSnapshot else {
                   completion(.failure(error!)); return
               }
               
               guard let brandName = documentSnapshot.get("brand_name") as? String else {
                   completion(.failure(FirestoreServiceError.documentNotFound)); return
               }
               
               completion(.success(brandName))
           }
       }
}

// MARK: - Firestore Service Errors
extension FirestoreService {
    private enum FirestoreServiceError: Error {
        case itemDecodingError
        case documentNotFound
        case userIdNotExist
        case userDocumentNotFound
        case brandNotExist
        case decodingError
    }
}
