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
            let document = try itemsReference.addDocument(from: item)
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

    /// Adding user info for user and returns this
    func saveUserInfo(customUser: CustomUser, completion: @escaping (Result<CustomUser, Error>) -> ()) {
        guard let userInfo = try? usersReference.addDocument(from: customUser) else {
            return completion(.failure(FirestoreServiceError.userEncodingError))
        }
        completion(.success(customUser))
    }
    
    func addFavoriteItem(to uid: String, item: Item?, completion: @escaping (Result<String, Error>) -> ()) {
//        usersReference.whereField("uid", isEqualTo: uid).getDocuments { querySnapshot, error in
//            guard let snapshot = querySnapshot else {
//                return completion(.failure(error!))
//            }
//            
//            let documents = snapshot.documents
//            for document in documents {
//                document.reference.setData(["favorites": ["1", "2"]], merge: true)
//            }
//            
//            completion(.success("huy suc"))
//        }
    }
}

// MARK: - Firestore Service Errors
extension FirestoreService {
    private enum FirestoreServiceError: Error {
        case documentNotFound
        case itemPhotoNotExist
        case itemAddError
        case itemDecodingError
        case userIdNotExist
        case userEncodingError
        case userDecodingError
    }
}
