import UIKit
import FirebaseFirestore
import FirebaseAuth
import FirebaseFirestoreSwift

// MARK: - UserService Protocol
protocol UserServiceProtocol {
    func getUserDocumentSnapshot(by id: String, completion: @escaping (Result<QueryDocumentSnapshot, Error>) -> ())
    func fetchUserSubscriptions(userId: String, completion: @escaping (Result<[String], Error>) -> ())
    func logout(completion: @escaping (Error?) -> ())
}

// MARK: - UserService Implementation
class UserService: UserServiceProtocol {
    private let firebaseDb = Firestore.firestore()

    /// Users reference
    private var usersReference: CollectionReference {
        return firebaseDb.collection("users")
    }
    
    /// Get user document snapshot. Returns QueryDocumentSnapshot
    /// This method required for prevent code duplicates
    func getUserDocumentSnapshot(by id: String, completion: @escaping (Result<QueryDocumentSnapshot, Error>) -> ()) {
        usersReference.whereField("id", isEqualTo: id).getDocuments { snapshot, error in
            guard let snapshot = snapshot,
                  !snapshot.isEmpty else {
                completion(.failure(UserServiceErrors.userNotExists)); return
            }
            
            guard let document = snapshot.documents.first else {
                completion(.failure(UserServiceErrors.documentNotFound)); return
            }
            
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
                        completion(.failure(UserServiceErrors.documentNotFound)); return
                    }
                    
                    let list = snapshot.documents.compactMap({ $0.get("brand_name") as? String })
                    completion(.success(list))
                }
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func logout(completion: @escaping (Error?) -> ()) {
        AuthService.sharedInstance.logout { error in
            guard error == nil else { completion(error); return }
        }
        
        SettingsService.sharedInstance.resetUserData()
        completion(nil)
    }
}

// MARK: - UserService Errors
extension UserService {
    private enum UserServiceErrors: Error {
        case userNotExists
        case documentNotFound
        case favItemAlreadyExists
    }
}

