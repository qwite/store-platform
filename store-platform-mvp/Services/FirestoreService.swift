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
    
    /// Creating new ad returns clothing name
    func createNewAd(item: Item, completion: @escaping (Result<String, Error>) -> ()) {
        do {
            let _ = try itemsReference.addDocument(from: item)
            completion(.success(item.clothingName))
        } catch {
            completion(.failure(error))
        }
    }
    
    /// Parse all ads and returns this
    func getAllItems(completion: @escaping (Result<[Item], Error>) -> ()) {
        itemsReference.getDocuments { snapshot, error in
            guard let snapshot = snapshot else {
                return completion(.failure(error!))
            }
            
            let documents = snapshot.documents
            let items = documents.compactMap { querySnapshot in
                return try? querySnapshot.data(as: Item.self)
            }

            completion(.success(items))
        }
    }        
    
    func getItemByDocumentId(documentId: String, completion: @escaping (Result<Item, Error>) -> ()) {
        itemsReference.document(documentId).getDocument { documentSnapshot, error in
            guard let documentSnapshot = documentSnapshot else {
                return debugPrint("document not found")
            }
            
            guard let item = try? documentSnapshot.data(as: Item.self) else {
                return debugPrint("decoding item error")
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
                
                debugPrint(snapshot.documents)
                guard let document = snapshot.documents.first else {
                    fatalError("document does not exist")
                }
                
                documentReference.collection("favorites").document(document.documentID).delete()
                completion(.success(""))
            }
        }
    }
    
    func addItemToCart(selectedSize: String, item: Item, completion: @escaping (Result<String, Error>) -> ()) {
        guard let userId = SettingsService.sharedInstance.userId else {
            return
        }
        
        usersReference.whereField("id", isEqualTo: userId).getDocuments { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                return completion(.failure(error!))
            }
            
            let documents = snapshot.documents
            guard var encodedItem = try? Firestore.Encoder().encode(item) else {
                return completion(.failure(FirestoreServiceError.itemEncodingError))
            }
            
            encodedItem["selected_size"] = selectedSize
            
            documents.last?.reference.setData(["cart": FieldValue.arrayUnion([encodedItem])], merge: true)
            completion(.success("added"))
        }
    }
    
    func getFavoritesIds(by userid: String, completion: @escaping (Result<[String], Error>) -> ()) {        
        usersReference.whereField("id", isEqualTo: userid).getDocuments { snapshot, error in
            guard let snapshot = snapshot else {
                return print(error!)
            }
            
            guard let document = snapshot.documents.last else {
                return print("document not found")
            }
            
            let documentReference = document.reference
            
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
        case userEncodingError
        case userDecodingError
    }
}
