import Foundation

protocol FavoritesPresenterProtocol {
    init(view: FavoritesViewProtocol, coordinator: FavoritesCoordinator)
    func viewDidLoad()
    func addFavoriteItemsObserver ()
    func insertFavoriteItems()
    func insertFavoriteItem(_ item: Item)
    func removeFavoriteItem(_ item: Item)
    func openDetailed(with item: Item)
    func openSizePicker(item: Item)
    func didSelectSize(selectedSize: Size, item: Item)
}

class FavoritesPresenter: FavoritesPresenterProtocol {
    weak var view: FavoritesViewProtocol?
    weak var coordinator: FavoritesCoordinator?
    
    required init(view: FavoritesViewProtocol, coordinator: FavoritesCoordinator) {
        self.view = view
        self.coordinator = coordinator
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
            
            self?.removeFavoriteItem(object)
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
    
    func removeFavoriteItem(_ item: Item) {
        FirestoreService.sharedInstance.removeFavoriteItem(item: item) { [weak self] result in
            switch result {
            case .success(let item):
                self?.view?.removeFavoriteItem(item)
            case .failure(let error):
                debugPrint(error)
            }
        }
    }
     
    
    func insertFavoriteItems() {
        FeedService.sharedInstance.getFavoriteItems { result in
            switch result {
            case .success(let items):
                self.view?.insertFavorites(items: items)
            case .failure(let error):
                debugPrint("error! : \(error)")
            }
        }
    }
    
    func openDetailed(with item: Item) {
        coordinator?.showDetailedAd(with: item)
    }
    
    func openSizePicker(item: Item) {
        guard let sizes = item.sizes else {
            return
        }
        
        coordinator?.showSizePicker(with: sizes)
        coordinator?.completionHandler = { [weak self] size in
            self?.didSelectSize(selectedSize: size, item: item)
        }
    }
    
    func didSelectSize(selectedSize: Size, item: Item) {
        guard let size = selectedSize.size else {
            return
        }
        
        FirestoreService.sharedInstance.addItemToCart(selectedSize: size, item: item) { [weak self] result in
            switch result {
            case .success(_):
                self?.view?.showSuccessAlert()
            case .failure(let error):
                debugPrint(error)
            }
        }
    }
}
