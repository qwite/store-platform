import Foundation

protocol FavoritesPresenterProtocol {
    init(view: FavoritesViewProtocol, coordinator: FavoritesCoordinator, service: UserServiceProtocol)
    func viewDidLoad()
    func addFavoriteItemsObserver ()
    func insertFavoriteItems()
    func insertFavoriteItem(_ item: Item)
    func removeFavoriteItem(_ item: Item)
    func removeFavoriteItemFromView(_ item: Item)
    func openDetailed(with item: Item)
    func openSizePicker(item: Item)
    func didAddToCart(item: CartItem)
}

class FavoritesPresenter: FavoritesPresenterProtocol {
    weak var view: FavoritesViewProtocol?
    weak var coordinator: FavoritesCoordinator?
    var service: UserServiceProtocol?
    
    required init(view: FavoritesViewProtocol, coordinator: FavoritesCoordinator, service: UserServiceProtocol) {
        self.view = view
        self.coordinator = coordinator
        self.service = service
    }
    
    deinit {
        let notificationName = Notification.Name("addFavoriteItem")
        NotificationCenter.default.removeObserver(self, name: notificationName, object: nil)
    }
    
    func viewDidLoad() {        
        addFavoriteItemsObserver()
        insertFavoriteItems()
        
        view?.configureCollectionView()
        view?.configureDataSource()
        view?.configureViews()
    }
    
    func addFavoriteItemsObserver () {
        let addNotificationName = Notification.Name("addFavoriteItem")
        let removeNotificationName = Notification.Name("removeFavoriteItem")
      
        NotificationCenter.default.addObserver(forName: addNotificationName, object: nil, queue: nil) { [weak self] notification in
            guard let object = notification.object as? Item else {
                return
            }
            
            self?.insertFavoriteItem(object)
        }
        
        NotificationCenter.default.addObserver(forName: removeNotificationName, object: nil, queue: nil) { [weak self] notification in
            guard let object = notification.object as? Item else {
                return
            }
            
            self?.removeFavoriteItemFromView(object)
        }
    }
    
    func insertFavoriteItem(_ item: Item) {
        if let itemsInSnapshot = view?.getItemsInSnapshot() {
            guard itemsInSnapshot.contains(where: {$0.id == item.id}) == false else {
                return debugPrint("item already exist")
            }
        }
        
        view?.insertFavorites(items: [item])
    }
    
    func removeFavoriteItemFromView(_ item: Item) {
        view?.removeFavoriteItem(item)
    }

    func removeFavoriteItem(_ item: Item) {
        service?.removeFavoriteItem(item: item, completion: { [weak self] result in
            switch result {
            case .success(let item):
                self?.view?.removeFavoriteItem(item)
            case .failure(let error):
                debugPrint(error)
            }
        })
    }
     
    func insertFavoriteItems() {
        service?.getFavoriteItems(completion: { [weak self] result in
            switch result {
            case .success(let items):
                self?.view?.insertFavorites(items: items)
            case .failure(let error):
                debugPrint(error)
            }
        })
    }
    
    func openDetailed(with item: Item) {
        coordinator?.showDetailedAd(with: item)
    }
    
    func openSizePicker(item: Item) {
        coordinator?.showSizePicker(for: item)
        coordinator?.completionHandler = { [weak self] item in
            print("test")
            self?.didAddToCart(item: item)
        }
    }
    
    func didAddToCart(item: CartItem) {
        service?.addItemToCart(item: item, completion: { [weak self] result in
            switch result {
            case .success(_):
                self?.view?.showSuccessAlert()
            case .failure(let error):
                debugPrint(error)
            }
        })
    }

}
