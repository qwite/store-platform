import Foundation

protocol FeedPresenterProtocol: AnyObject {
    init(view: FeedViewProtocol, coordinator: FeedCoordinator, service: UserServiceProtocol)
    func viewDidLoad()
    func getAds()
    func openDetailed(item: Item)
    func addFavorite(item: Item)
    func removeFavorite(item: Item)
}

class FeedPresenter: FeedPresenterProtocol {
    weak var view: FeedViewProtocol?
    weak var coordinator: FeedCoordinator?
    var service: UserServiceProtocol?
    
    required init(view: FeedViewProtocol, coordinator: FeedCoordinator, service: UserServiceProtocol) {
        self.view = view
        self.coordinator = coordinator
        self.service = service
    }
    
    func viewDidLoad() {
        view?.configureCollectionView()
        view?.configureDataSource()
        view?.configureViews()
        getAds()
        checkLogin()
        fetch()
    }
    
    func fetch() {
//        RealTimeService.sharedInstance.createNode(for: "wiWH1iujhw5CS6yoPEhT", with: "Extra brand") { error in
//            guard error == nil else {
//                fatalError("\(error!)")
//            }
//
//            print("node created")
//        }
        
//        RealTimeService.sharedInstance.getAllConversationsForBrand(brandId: "wiWH1iujhw5CS6yoPEhT") { result in
//            switch result {
//            case .success(let conversations):
//                print(conversations)
//            case .failure(let error):
//                fatalError("\(error)")
//            }
//        }
    }
    
    
    func postNotificationAddFavoriteItem(_ item: Item) {
        let notificationName = Notification.Name("addFavoriteItem")
        NotificationCenter.default.post(name: notificationName, object: item)
    }
    
    func postNotificationRemoveFavoriteItem(_ item: Item) {
        let notificationName = Notification.Name("removeFavoriteItem")
        NotificationCenter.default.post(name: notificationName, object: item)
    }
    
    func getAds() {
        FirestoreService.sharedInstance.getAllItems { [weak self] result in
            switch result {
            case .success(let items):
                self?.view?.insertAds(items: items)
            case .failure(let error):
                debugPrint(error)
            }
        }
    }
    
    func addFavorite(item: Item) {
        service?.addFavoriteItem(item: item, completion: { [weak self] result in
            switch result {
            case .success(let item):
                self?.postNotificationAddFavoriteItem(item)
            case .failure(let error):
                debugPrint(error)
            }
        })
    }
    
    func removeFavorite(item: Item) {
        service?.removeFavoriteItem(item: item, completion: { [weak self] result in
            switch result {
            case .success(_):
                self?.postNotificationRemoveFavoriteItem(item)
            case .failure(let error):
                debugPrint(error)
            }
        })
    }
    
    func test() {
        print("removed action...")
    }
    
    func openDetailed(item: Item) {
        guard let id = item.id else {
            fatalError()
        }
        
        service?.increaseItemViews(itemId: id, completion: { result in
            switch result {
            case .success(let message):
                debugPrint(message)
            case .failure(let error):
                debugPrint(error)
            }
        })
        
        coordinator?.showDetailedAd(with: item)
    }
    
    //MARK: - debug
    #if DEBUG
    func checkLogin() {
        debugPrint("Авторизован?: \(SettingsService.sharedInstance.isAuthorized)")
    }
    #endif

    
    func resetLogin() {
        SettingsService.sharedInstance.isAuthorized = false
    }
}
