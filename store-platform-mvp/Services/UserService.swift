import UIKit

protocol UserServiceProtocol: AnyObject {
    func logout(completion: @escaping (Error?) -> ())

    func addItemToCart(item: CartItem, completion: @escaping (Result<CartItem, Error>) -> ())
    func getItemsFromCart(completion: @escaping (Result<[CartItem], Error>) -> ())
    func addFavoriteItem(item: Item, completion: @escaping (Result<Item, Error>) -> ())
    func removeFavoriteItem(item: Item, completion: @escaping (Result<Item, Error>) -> ())
    func getFavoriteItems(completion: @escaping (Result<[Item], Error>) -> ())
    func uploadBrandLogoImage(data: Data, completion: @escaping (Result<String, Error>) -> ())
    func createBrand(brand: Brand, completion: @escaping (Result<String, Error>) -> ())
    func increaseItemViews(itemId: String, completion: @escaping (Result<String, Error>) -> ())
    func getBrandName(completion: @escaping (Result<String, Error>) -> ())
    func getBrandId(completion: @escaping (Result<String, Error>) -> ())
    func getItemViewsBrand(completion: @escaping (Result<[MonthlyViews], Error>) -> ())
    func getItemSalesFromBrand(completion: @escaping (Result<[Item], Error>) -> ())
    func getItemsFromBrand(completion: @escaping (Result<[Item], Error>) -> ())
    func addItemToBrand(item: Item, completion: @escaping (Result<String, Error>) -> ())
}

class UserService: UserServiceProtocol {
    
    deinit {
        debugPrint("user service deinit")
    }
    
    func logout(completion: @escaping (Error?) -> ()) {
        AuthService.sharedInstance.logout { error in
            guard error == nil else { completion(error); return }
        }
        
        SettingsService.sharedInstance.resetUserData()
    }
    
    func getBrandId(completion: @escaping (Result<String, Error>) -> ()) {
        guard let userId = SettingsService.sharedInstance.userId else {
            return completion(.failure(UserServiceError.inputDataError))
        }
        
        FirestoreService.sharedInstance.getBrandId(userId: userId) { result in
            switch result {
            case .success(let brandId):
                completion(.success(brandId))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func addItemToCart(item: CartItem, completion: @escaping (Result<CartItem, Error>) -> ()) {
        guard let userId = SettingsService.sharedInstance.userId else {
            return completion(.failure(UserServiceError.inputDataError))
        }
        
        FirestoreService.sharedInstance.addItemToCart(userId: userId, selectedItem: item) { result in
            switch result {
            case .success(_):
                completion(.success(item))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func getItemsFromCart(completion: @escaping (Result<[CartItem], Error>) -> ()) {
        guard let userId = SettingsService.sharedInstance.userId else {
            return completion(.failure(UserServiceError.inputDataError))
        }
        
        FirestoreService.sharedInstance.getItemsFromCart(userId: userId) { result in
            switch result {
            case .success(let items):
                completion(.success(items))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func addFavoriteItem(item: Item, completion: @escaping (Result<Item, Error>) -> ()) {
        guard let itemId = item.id,
              let userId = SettingsService.sharedInstance.userId else {
            return completion(.failure(UserServiceError.inputDataError))
        }
        
        FirestoreService.sharedInstance.addFavoriteItem(userId: userId, itemId: itemId) { error in
            guard error == nil else { completion(.failure(error!)); return }
            let logMessage = "[Log] Added to favorites"
            debugPrint(logMessage)
            completion(.success(item))
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
    
    func uploadBrandLogoImage(data: Data, completion: @escaping (Result<String, Error>) -> ()) {
        StorageService.sharedInstance.uploadImage(with: data, type: .brandLogo) { result in
            switch result {
            case .success(let url):
                completion(.success(url))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func createBrand(brand: Brand, completion: @escaping (Result<String, Error>) -> ()) {
        guard let userId = SettingsService.sharedInstance.userId else {
            return completion(.failure(UserServiceError.someError))
        }
        
        FirestoreService.sharedInstance.createBrand(userId: userId, brand: brand) { result in
            switch result {
            case .success(let dict):
                guard let brandId = dict["brand_id"],
                      let brandName = dict["brand_name"] else {
                    return completion(.failure(UserServiceError.someError))
                }
                
                RealTimeService.sharedInstance.createNode(for: brandId, with: brandName) { error in
                    guard error == nil else {
                        return completion(.failure(error!))
                    }
                    
                    completion(.success("brand created"))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func getSellerStatus(completion: @escaping (Result<Bool, Error>) -> ()) {
        guard let userId = SettingsService.sharedInstance.userId else {
            return completion(.failure(UserServiceError.localUserNotExist))
        }
        FirestoreService.sharedInstance.getSellerStatus(userId: userId) { result in
            switch result {
            case .success(_):
                completion(.success(true))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func increaseItemViews(itemId: String, completion: @escaping (Result<String, Error>) -> ()) {
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_GB")
        dateFormatter.setLocalizedDateFormatFromTemplate("MMM")
        let month = dateFormatter.string(from: currentDate)
        dateFormatter.setLocalizedDateFormatFromTemplate("d")
        let day = Int(dateFormatter.string(from: currentDate))!
        
        FirestoreService.sharedInstance.increaseItemViewsCounter(month: month, day: day, itemId: itemId) { result in
            switch result {
            case .success(let message):
                completion(.success(message))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func getBrandName(completion: @escaping (Result<String, Error>) -> ()) {
        guard let userId = SettingsService.sharedInstance.userId else {
            return completion(.failure(UserServiceError.localUserNotExist))
        }
        
        FirestoreService.sharedInstance.getBrandId(userId: userId) { result in
            switch result {
            case .success(let brandId):
                FirestoreService.sharedInstance.getBrandName(brandId: brandId) { result in
                    switch result {
                    case .success(let brandName):
                        completion(.success(brandName))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func getItemsFromBrand(completion: @escaping (Result<[Item], Error>) -> ()) {
        guard let userId = SettingsService.sharedInstance.userId else {
            return completion(.failure(UserServiceError.localUserNotExist))
        }
        
        FirestoreService.sharedInstance.getBrandId(userId: userId) { result in
            switch result {
            case .success(let brandId):
                FirestoreService.sharedInstance.getItemIdsFromBrand(brandId: brandId) { result in
                    switch result {
                    case .success(let ids):
                        var items: [Item] = []
                        let group = DispatchGroup()
                        for value in ids {
                            group.enter()
                            FirestoreService.sharedInstance.getItemByDocumentId(documentId: value) { result in
                                defer { group.leave() }
                                switch result {
                                case .success(let item):
                                    items.append(item)
                                case .failure(let error):
                                    completion(.failure(error))
                                }
                            }
                        }
                        
                        group.notify(queue: .main) {
                            completion(.success(items))
                        }
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func addItemToBrand(item: Item, completion: @escaping (Result<String, Error>) -> ()) {
        guard let userId = SettingsService.sharedInstance.userId else {
            return completion(.failure(UserServiceError.localUserNotExist))
        }
        
        FirestoreService.sharedInstance.getBrandId(userId: userId) { result in
            switch result {
            case .success(let brandId):
                FirestoreService.sharedInstance.createAd(item: item) { result in
                    switch result {
                    case .success(let itemId):
                        FirestoreService.sharedInstance.putItemIdInBrand(brandId: brandId, itemId: itemId) { error in
                            guard error == nil else { completion(.failure(error!)); return }
                            
                            completion(.success("added"))
                        }
                        
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    
    
    // lol ..
    func getItemViewsBrand(completion: @escaping (Result<[MonthlyViews], Error>) -> ()) {
        guard let userId = SettingsService.sharedInstance.userId else {
            return completion(.failure(UserServiceError.localUserNotExist))
        }
        
        FirestoreService.sharedInstance.getBrandId(userId: userId) { result in
            switch result {
            case .success(let brandId):
                FirestoreService.sharedInstance.getItemIdsFromBrand(brandId: brandId) { result in
                    switch result {
                    case .success(let items):
                        FirestoreService.sharedInstance.getViewsAmountFromItems(items: items) { result in
                            switch result {
                            case .success(let views):
                                completion(.success(views))
                            case .failure(let error):
                                completion(.failure(error))
                            }
                        }
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func getItemSalesFromBrand(completion: @escaping (Result<[Item], Error>) -> ()) {
        guard let userId = SettingsService.sharedInstance.userId else {
            return completion(.failure(UserServiceError.localUserNotExist))
        }
        
        FirestoreService.sharedInstance.getBrandId(userId: userId) { result in
            switch result {
            case .success(let brandId):
                FirestoreService.sharedInstance.getItemIdsFromBrandSales(brandId: brandId) { result in
                    switch result {
                    case .success(let itemsId):
                        let group = DispatchGroup()
                        var items: [Item] = []
                        for id in itemsId {
                            group.enter()
                            FirestoreService.sharedInstance.getItemByDocumentId(documentId: id) { result in
                                defer { group.leave() }
                                switch result {
                                case .success(let name):
                                    items.append(name)
                                case .failure(let error):
                                    completion(.failure(error))
                                }
                            }
                        }
                        group.notify(queue: .main) {
                            completion(.success(items))
                        }
                        
                    case .failure(let error):
                        completion(.failure(error))
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
        case localUserNotExist
    }
}
