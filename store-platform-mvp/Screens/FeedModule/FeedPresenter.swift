import Foundation

// MARK: - FeedPresenterProtocol
protocol FeedPresenterProtocol: AnyObject {
    init(view: FeedViewProtocol,
         coordinator: FeedCoordinator,
         service: FeedServiceProtocol,
         userService: UserServiceProtocol,
         favoritesService: FavoritesServiceProtocol,
         items: [Item]?)
    
    func viewDidLoad()
    
    func fetchItems()
    func getItems()
    func getSubscriptionItems()
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
    var favoritesService: FavoritesServiceProtocol?
    
    var items: [Item]?
    
    required init(view: FeedViewProtocol,
                  coordinator: FeedCoordinator,
                  service: FeedServiceProtocol,
                  userService: UserServiceProtocol,
                  favoritesService: FavoritesServiceProtocol,
                  items: [Item]?) {
        self.view = view
        self.coordinator = coordinator
        self.service = service
        self.userService = userService
        self.favoritesService = favoritesService
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
    
    func getSubscriptionItems() {
        guard let userId = SettingsService.sharedInstance.userId else { return }
        userService?.fetchUserSubscriptions(userId: userId, completion: { [weak self] result in
            switch result {
            case .success(let subscriptionList):
                self?.service?.fetchSubscriptionItems(subscriptionList: subscriptionList, completion: { [weak self] result in
                    switch result {
                    case .success(let items):
                        self?.view?.insertItems(items: items)
                    case .failure(let error):
                        fatalError("\(error)")
                    }
                })
            case .failure(let error):
                fatalError("\(error)")
            }
        })
    }
    
    func addFavorite(item: Item) {
        guard let userId = SettingsService.sharedInstance.userId else { return }
        favoritesService?.addFavoriteItem(item: item, userId: userId, completion: { [weak self] result in
            switch result {
            case .success(let item):
                self?.postNotificationAddFavoriteItem(item)
            case .failure(let error):
                fatalError("\(error)")
            }
        })
    }
    
    func removeFavorite(item: Item) {
        guard let userId = SettingsService.sharedInstance.userId else { return }
        favoritesService?.removeFavoriteItem(item: item, userId: userId, completion: { [weak self] result in
            switch result {
            case .success(_):
                self?.postNotificationRemoveFavoriteItem(item)
            case .failure(let error):
                fatalError("\(error)")
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
