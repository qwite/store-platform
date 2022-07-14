import UIKit
import FirebaseFirestore
import FirebaseAuth
import FirebaseFirestoreSwift

class UserService2 {
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
                completion(.failure(UserService2Errors.userNotExist)); return
            }
            
            guard let document = snapshot.documents.first else {
                completion(.failure(UserService2Errors.documentNotFound)); return
            }
            
            completion(.success(document))
        }
    }
    
    /// Get user subscription list. Returns [String]
    func fetchUserSubscriptions(userId: String, completion: @escaping (Result<[String], Error>) -> ()) {
        self.getUserDocumentSnapshot(by: userId) { result in
            switch result {
            case .success(let snapshot):
                let reference = snapshot.reference
                let collection = reference.collection("subscriptions")
                
                collection.getDocuments { snapshot, error in
                    guard let snapshot = snapshot, !snapshot.isEmpty else {
                        completion(.failure(UserService2Errors.documentNotFound)); return
                    }
                    
                    let list = snapshot.documents.compactMap({ $0.get("brand_name") as? String })
                    completion(.success(list))
                }
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

extension UserService2 {
    private enum UserService2Errors: Error {
        case userNotExist
        case documentNotFound
    }
}

