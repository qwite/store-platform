import UIKit

protocol UserServiceProtocol: AnyObject {
    func addFavoriteItem(item: Item, completion: @escaping (Result<Item, Error>) -> ())
    func removeFavoriteItem(item: Item, completion: @escaping (Result<Item, Error>) -> ())
    func getFavoriteItems(completion: @escaping (Result<[Item], Error>) -> ())
}

class UserService: UserServiceProtocol {
    func addFavoriteItem(item: Item, completion: @escaping (Result<Item, Error>) -> ()) {
        guard let itemId = item.id,
              let userId = SettingsService.sharedInstance.userId else {
            return completion(.failure(UserServiceError.inputDataError))
        }
        
        FirestoreService.sharedInstance.addFavoriteItem(userId: userId, itemId: itemId) { result in
            switch result {
            case .success(_):
                completion(.success(item))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func removeFavoriteItem(item: Item, completion: @escaping (Result<Item, Error>) -> ()) {
        guard let itemId = item.id,
              let userId = SettingsService.sharedInstance.userId else {
            return completion(.failure(UserServiceError.inputDataError))
        }
        
        FirestoreService.sharedInstance.removeFavoriteItem(userId: userId, itemId: itemId) { result in
            switch result {
            case .success(_):
                completion(.success(item))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    // bad solution -> TODO: fix
    func getFavoriteItems(completion: @escaping (Result<[Item], Error>) -> ()) {
        guard let userId = SettingsService.sharedInstance.userId else {
            return
        }
        
        FirestoreService.sharedInstance.getFavoritesIds(by: userId) { result in
            switch result {
            case .success(let data):
                var items: [Item] = []
                for documentId in data {
                    FirestoreService.sharedInstance.getItemByDocumentId(documentId: documentId) { result in
                        guard let item = try? result.get() else {
                            return completion(.failure(UserServiceError.someError))
                        }
                        
                        items.append(item)
                        if items.count == data.count {
                            completion(.success(items))
                        }
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

extension UserService {
    enum UserServiceError: Error {
        case someError
        case inputDataError
    }
}
