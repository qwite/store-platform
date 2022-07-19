import UIKit
import FirebaseFirestore
import FirebaseFirestoreSwift

// MARK: - CartService Protocol
protocol CartServiceProtocol {
    func addItemCart(userId: String, cartItem: Cart, completion: @escaping (Result<Cart, Error>) -> ())
    func removeItemCart(userId: String, cartItem: Cart, completion: @escaping (Error?) -> ())
    func fetchItemsCart(userId: String, completion: @escaping (Result<[Cart], Error>) -> ())
    func fetchItem(by id: String, completion: @escaping (Result<Item, Error>) -> ())
    func createOrder(userId: String, items: [Cart], date: String, userData: UserData, complection: @escaping (Error?) -> ())
}

// MARK: - CartServiceProtocol Implementation
class CartService: CartServiceProtocol {
    private let firebaseDb = Firestore.firestore()
    
    /// Brands reference
    private var brandsReference: CollectionReference {
        return firebaseDb.collection("brands")
    }
    
    /// Orders reference
    private var ordersReference: CollectionReference {
        return firebaseDb.collection("orders")
    }
    
    func addItemCart(userId: String, cartItem: Cart, completion: @escaping (Result<Cart, Error>) -> ()) {
        FirestoreService.sharedInstance.getUserDocumentSnapshot(by: userId) { result in
            switch result {
            case .success(let document):
                let cartCollection = document.reference.collection("cart")
                guard let _ = try? cartCollection.addDocument(from: cartItem, completion: { error in
                    guard error == nil else { completion(.failure(error!)); return }
                }) else {
                    completion(.failure(CartServiceErrors.itemEncodingError)); return
                }
                
                completion(.success(cartItem))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func removeItemCart(userId: String, cartItem: Cart, completion: @escaping (Error?) -> ()) {
        FirestoreService.sharedInstance.getUserDocumentSnapshot(by: userId) { result in
            switch result {
            case .success(let document):
                let cartCollection = document.reference.collection("cart")
                let itemId = cartItem.itemId
                cartCollection.whereField("item_id", isEqualTo: itemId).getDocuments { snapshot, error in
                    guard let snapshot = snapshot,
                          !snapshot.isEmpty,
                          let document = snapshot.documents.first else {
                        completion(CartServiceErrors.documentsNotExist); return
                    }
                    
                    cartCollection.document(document.documentID).delete { error in
                        guard error == nil else { completion(error!); return }
                        completion(nil)
                    }
                }
                
            case .failure(let error):
                completion(error)
            }
        }
    }
    
    func fetchItemsCart(userId: String, completion: @escaping (Result<[Cart], Error>) -> ()) {
        FirestoreService.sharedInstance.getUserDocumentSnapshot(by: userId) { result in
            switch result {
            case .success(let document):
                let cartCollection = document.reference.collection("cart")
                cartCollection.getDocuments { snapshot, error in
                    guard let snapshot = snapshot, !snapshot.isEmpty else {
                        completion(.failure(CartServiceErrors.documentsNotExist)); return
                    }
                    
                    let items = snapshot.documents.compactMap({ try? $0.data(as: Cart.self) })
                    completion(.success(items))
                }
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func fetchItem(by id: String, completion: @escaping (Result<Item, Error>) -> ()) {
        FirestoreService.sharedInstance.getItemByDocumentId(documentId: id) { result in
            switch result {
            case .success(let item):
                completion(.success(item))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // TODO: 
    func createOrder(userId: String, items: [Cart], date: String, userData: UserData, complection: @escaping (Error?) -> ()) {}
}

// MARK: - Private helpers
extension CartService {
    func getBrandId(brandName: String, completion: @escaping (Result<String, Error>) -> ()) {
        brandsReference.whereField("brand_name", isEqualTo: brandName).getDocuments { snapshot, error in
            guard let snapshot = snapshot,
                  !snapshot.isEmpty,
                  let document = snapshot.documents.first else {
                completion(.failure(CartServiceErrors.documentsNotExist)); return
            }
            
            // Success action
            completion(.success(document.documentID))
        }
    }
}

// MARK: - CartServiceErrors Errors
extension CartService {
    private enum CartServiceErrors: Error {
        case itemEncodingError
        case documentsNotExist
    }
}
