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
    func getUserInfo(by id: String, completion: @escaping (Result<[String: Any], Error>) -> ()) {
        usersReference.whereField("uid", isEqualTo: id).getDocuments { snapshot, error in
            guard let snapshot = snapshot else {
                return completion(.failure(FirestoreServiceError.documentNotFound))
            }

            let document = snapshot.documents.first
            guard let document = document else {
                return completion(.failure(FirestoreServiceError.documentNotFound))
            }

            let userInfo = document.data()
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
        let userInfo = customUser.encodeUserInfo()
        usersReference.addDocument(data: userInfo)
        completion(.success(customUser))
    }
}

// MARK: - Firestore Service Errors
extension FirestoreService {
    private enum FirestoreServiceError: Error {
        case documentNotFound
        case itemPhotoNotExist
        case itemAddError
        case itemDecodingError
    }
}
