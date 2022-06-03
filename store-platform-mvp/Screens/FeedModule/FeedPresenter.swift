import Foundation

protocol FeedPresenterProtocol: AnyObject {
    init(view: FeedViewProtocol, coordinator: FeedCoordinator)
    func viewDidLoad()
    func getAds()
    func openDetailed(item: Item) 
}

class FeedPresenter: FeedPresenterProtocol {
    weak var view: FeedViewProtocol?
    weak var coordinator: FeedCoordinator?
    
    required init(view: FeedViewProtocol, coordinator: FeedCoordinator) {
        self.view = view
        self.coordinator = coordinator
    }
    
    func viewDidLoad() {
        view?.configureCollectionView()
        view?.configureDataSource()
        view?.configureViews()
        getAds()
        checkLogin()
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
        FirestoreService.sharedInstance.addFavoriteItem(item: item) { [weak self] result in
            switch result {
            case .success(_):
                self?.postNotificationAddFavoriteItem(item)
                debugPrint("added")
            case .failure(let error):
                debugPrint(error)
            }
        }
    }
    
    func removeFavorite(item: Item) {
        FirestoreService.sharedInstance.removeFavoriteItem(item: item) { [weak self] result in
            switch result {
            case .success(_):
                self?.postNotificationRemoveFavoriteItem(item)
                debugPrint("removed")
            case .failure(let error):
                debugPrint(error)
            }
        }
    }
    
    func openDetailed(item: Item) {
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
