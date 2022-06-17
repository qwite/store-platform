import Foundation

protocol FeedPresenterProtocol: AnyObject {
    init(view: FeedViewProtocol, coordinator: FeedCoordinator, service: UserServiceProtocol, items: [Item]?)
    func viewDidLoad()
    
    func fetchItems()
    func getAds()
    func openDetailed(item: Item)
    func openSearch()
    func openSortingFeed()
    func searchItems(by brand: String)
    func addFavorite(item: Item)
    func removeFavorite(item: Item)
}

class FeedPresenter: FeedPresenterProtocol {
    weak var view: FeedViewProtocol?
    weak var coordinator: FeedCoordinator?
    var service: UserServiceProtocol?
    
    var items: [Item]?
    
    required init(view: FeedViewProtocol, coordinator: FeedCoordinator, service: UserServiceProtocol, items: [Item]?) {
        self.view = view
        self.coordinator = coordinator
        self.service = service
        
        self.items = items
    }
    
    func viewDidLoad() {
        view?.configureCollectionView()
        view?.configureDataSource()
        view?.configureViews()
        view?.configureButtons()
        
        fetchItems()

        checkLogin()
        
//        sortTestItems()
    
    }
    
    func fetchItems() {
        guard let items = self.items, let firstItem = items.first else {
            self.getAds(); return
        }
        
        self.view?.insertAds(items: items)
        self.view?.removeSearchBar(category: firstItem.category)
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
    
    func openSearch() {
        coordinator?.showSearchScreen()
    }
    
    func searchItems(by brand: String) {
        FirestoreService.sharedInstance.getItemsByBrand(brand: brand) {  result in
            switch result {
            case .success(let items):
                self.view?.updateDataSource(with: items)
            case .failure(_):
                break
            }
        }
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
    
    func openSortingFeed() {
        coordinator?.showSortingFeed()
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

// MARK: - SortingFeedPresenterDelegate
extension FeedPresenter: SortingFeedPresenterDelegate {
    func insertSortedItems(items: [Item]) {
        self.view?.updateDataSource(with: items)
    }
    
    func insertPopularItems(items: [ItemViews]) {
        let sortedItems = items.sorted(by: { $0.views > $1.views })
        let resultItems: [Item] = sortedItems.map({ $0.item })
        self.view?.updateDataSource(with: resultItems)
    }
}
