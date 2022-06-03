import Foundation

class FeedService {
    static let sharedInstance = FeedService()
    private init() {}
    
    // bad solution :(
    func getFavoriteItems(completion: @escaping (Result<[Item], Error>) -> ()) {
        var items: [Item] = []
        FirestoreService.sharedInstance.getFavoritesIds { result in
            guard let data = try? result.get() else {
                return debugPrint("not success result")
            }
            
            for (_, val) in data.enumerated() {
                FirestoreService.sharedInstance.getItemByDocumentId(documentId: val) { result in
                    guard let new = try? result.get() else {
                        return debugPrint("not work")
                    }
                    
                    items.append(new)
                    if data.count == items.count {
                        completion(.success(items))
                    }
                }
            }
        }
    }
}
