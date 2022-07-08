import Foundation

// MARK: - FeedPresenterProtocol
protocol FeedPresenterProtocol: AnyObject {
    init(view: FeedViewProtocol,
         coordinator: FeedCoordinator,
         service: FeedServiceProtocol,
         userService: UserServiceProtocol,
         items: [Item]?)
    
    func viewDidLoad()
    
    func fetchItems()
    func getItems()
    func getUserSubscriptions()
    func openDetails(item: Item)
    func openSearch()
    func openSortingFeed()
    func searchItems(by brand: String)
    func addFavorite(item: Item)
    func removeFavorite(item: Item)
}

// MARK: - FeedPresenterProtocol Implementation
class FeedPresenter: FeedPresenterProtocol {
    weak var view: FeedViewProtocol?
    weak var coordinator: FeedCoordinator?
    
    var service: FeedServiceProtocol?
    var userService: UserServiceProtocol?
    var items: [Item]?
    
    required init(view: FeedViewProtocol,
                  coordinator: FeedCoordinator,
                  service: FeedServiceProtocol,
                  userService: UserServiceProtocol,
                  items: [Item]?) {
        self.view = view
        self.coordinator = coordinator
        self.service = service
        self.userService = userService
        self.items = items
    }
    
    func viewDidLoad() {
        view?.configureCollectionView()
        view?.configureDataSource()
        view?.configureViews()
        view?.configureButtons()
        view?.configureNavigationRightButtons()
        
        fetchItems()
    }
    
    func fetchItems() {
        guard let items = self.items, let firstItem = items.first else {
            self.getItems(); return
        }
        
        self.view?.insertItems(items: items)
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
    
    func getItems() {
        service?.fetchAllItems(by: nil, completion: { [weak self] result in
            switch result {
            case .success(let items):
                self?.view?.insertItems(items: items)
            case .failure(let error):
                fatalError("\(error)")
            }
        })
    }
    
    // TODO: remove firestore service
    func getUserSubscriptions() {
        guard let userId = SettingsService.sharedInstance.userId else { return }
        FirestoreService.sharedInstance.getSubscriptionsItems(userId: userId) { [weak self] result in
            switch result {
            case .success(let items):
                self?.view?.insertItems(items: items)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func addFavorite(item: Item) {
        userService?.addFavoriteItem(item: item, completion: { [weak self] result in
            switch result {
            case .success(let item):
                self?.postNotificationAddFavoriteItem(item)
            case .failure(let error):
                debugPrint(error)
            }
        })
    }
    
    func removeFavorite(item: Item) {
        userService?.removeFavoriteItem(item: item, completion: { [weak self] result in
            switch result {
            case .success(_):
                self?.postNotificationRemoveFavoriteItem(item)
            case .failure(let error):
                debugPrint(error)
            }
        })
    }
    
    func openSearch() {
        coordinator?.showSearchScreen()
    }
    
    func searchItems(by brand: String) {
        service?.fetchItemsByBrandName(brand: brand) { result in
            switch result {
            case .success(let items):
                self.view?.updateDataSource(with: items)
            case .failure(_):
                break
            }
        }
    }
    
    func openDetails(item: Item) {
        coordinator?.showDetailedAd(with: item)
    }
    
    func openSortingFeed() {
        coordinator?.showSortingFeed()
    }
}

// MARK: - SortingFeedPresenterDelegate
extension FeedPresenter: SortingFeedPresenterDelegate {
    func insertSortedItems(items: [Item]) {
        self.view?.updateDataSource(with: items)
    }
    
    func insertPopularItems(items: [Item]) {
        self.view?.updateDataSource(with: items)
    }
    
    func resetSettings() {
        self.getItems()
    }
}
