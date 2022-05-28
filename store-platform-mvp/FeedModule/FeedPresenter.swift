import Foundation

protocol FeedPresenterProtocol: AnyObject {
    init(view: FeedViewProtocol, coordinator: FeedCoordinator)
    func viewDidLoad()
    func getAds()
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
        resetLogin()
        checkLogin()
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
    
    func addFavorite(itemId: String?) {
        FirestoreService.sharedInstance.addFavoriteItem(itemId: itemId) { result in
            switch result {
            case .success(let message):
                debugPrint(message)
            case .failure(let error):
                debugPrint(error)
            }
        }
    }
    
    func removeFavorite(itemId: String?) {
        FirestoreService.sharedInstance.removeFavoriteItem(itemId: itemId) { result in
            switch result {
            case .success(let message):
                debugPrint(message)
            case .failure(let error):
                debugPrint(error)
            }
        }
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
