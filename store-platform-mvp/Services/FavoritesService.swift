import UIKit
import FirebaseFirestore
import FirebaseFirestoreSwift

// MARK: - FavoritesService Protocol
protocol FavoritesServiceProtocol {
    func fetchFavoritesId(userId: String, completion: @escaping (Result<[String], Error>) -> ())
    func fetchFavoritesItems(userId: String, completion: @escaping (Result<[Item], Error>) -> ())
    func addFavoriteItem(item: Item, userId: String, completion: @escaping (Result<Item, Error>) -> ())
    func removeFavoriteItem(item: Item, userId: String, completion: @escaping (Result<Item, Error>) -> ())
}

// MARK: - FavoritesServiceProtocol Implementation
class FavoritesService: FavoritesServiceProtocol {
    private let firebaseDb = Firestore.firestore()
    
    func fetchFavoritesId(userId: String, completion: @escaping (Result<[String], Error>) -> ()) {
        FirestoreService.sharedInstance.getUserDocumentSnapshot(by: userId) { result in
            switch result {
            case .success(let document):
                let favoritesCollection = document.reference.collection("favorites")
                favoritesCollection.getDocuments { snapshot, error in
                    guard let snapshot = snapshot, !snapshot.isEmpty else {
                        completion(.failure(FavoritesServiceErrors.documentsNotFound)); return
                    }
                    
                    let favoritesId = snapshot.documents.compactMap({ $0.get("item_id") as? String })
                    completion(.success(favoritesId))
                }
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func fetchFavoritesItems(userId: String, completion: @escaping (Result<[Item], Error>) -> ()) {
        self.fetchFavoritesId(userId: userId) { result in
            switch result {
            case .success(let favoritesId):
                var favoritesItems: [Item] = []
                for documentId in favoritesId {
                    FirestoreService.sharedInstance.getItemByDocumentId(documentId: documentId) { result in
                        switch result {
                        case .success(let item):
                            favoritesItems.append(item)
                            if favoritesItems.count == favoritesId.count {
                                completion(.success(favoritesItems))
                            }
                            
                        case .failure(let error):
                            completion(.failure(error))
                        }
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    /// Adding to collection 'favorites' item. Returns Item
    func addFavoriteItem(item: Item, userId: String, completion: @escaping (Result<Item, Error>) -> ()) {
        guard let itemId = item.id else { return }
        FirestoreService.sharedInstance.getUserDocumentSnapshot(by: userId) { result in
            switch result {
            case .success(let document):
                let favoritesCollection = document.reference.collection("favorites")
                
                // Check if item already exist in 'favorites' user collection
                favoritesCollection.whereField("item_id", isEqualTo: itemId).getDocuments { snapshot, error in
                    guard let snapshot = snapshot, snapshot.documents.first == nil else {
                        completion(.failure(FavoritesServiceErrors.favoriteItemAlreadyExists)); return
                    }
                    
                    favoritesCollection.addDocument(data: ["item_id": itemId]) { error in
                        guard error == nil else { completion(.failure(error!)); return }
                        completion(.success(item))
                    }
                }
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    /// Removing item from 'favorites' collection. Returns Item
    func removeFavoriteItem(item: Item, userId: String, completion: @escaping (Result<Item, Error>) -> ()) {
        guard let itemId = item.id else { return }
        FirestoreService.sharedInstance.getUserDocumentSnapshot(by: userId) { result in
            switch result {
            case .success(let document):
                let favoritesCollection = document.reference.collection("favorites")
                favoritesCollection.whereField("item_id", isEqualTo: itemId).getDocuments { snapshot, error in
                    guard let snapshot = snapshot,
                          !snapshot.isEmpty,
                          let favDocument = snapshot.documents.first else {
                        completion(.failure(FavoritesServiceErrors.documentsNotFound)); return
                    }
                    
                    favoritesCollection.document(favDocument.documentID).delete { error in
                        guard error == nil else { completion(.failure(error!)); return }
                        completion(.success(item))
                    }
                }
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

extension FavoritesService {
    private enum FavoritesServiceErrors: Error {
        case documentsNotFound
        case favoriteItemAlreadyExists
    }
}
