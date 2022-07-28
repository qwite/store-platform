import Foundation

// MARK: - CartPresenterProtocol
protocol CartPresenterProtocol {
    init(view: CartViewProtocol, service: CartServiceProtocol, userService: UserServiceProtocol, coordinator: CartCoordinator)
    func viewDidAppear()
    func viewDidLoad()
    func finish()
    
    func setTotalPrice(items: [Cart])
    func removeItem(item: Cart)
    func getItem(id: String, completion: @escaping (Item) -> ())

    func createOrder()
}

// MARK: - CartPresenterProtocol Implementation
class CartPresenter: CartPresenterProtocol {
    weak var view: CartViewProtocol?
    weak var coordinator: CartCoordinator?
    
    var service: CartServiceProtocol?
    var userService: UserServiceProtocol?
        
    required init(view: CartViewProtocol, service: CartServiceProtocol, userService: UserServiceProtocol, coordinator: CartCoordinator) {
        self.view = view
        self.service = service
        self.userService = userService
        self.coordinator = coordinator
    }
    
    func viewDidAppear() {
        DispatchQueue.main.async {
            self.getCartItems()
        }
    }
    
    func viewDidLoad() {
        view?.configureCollectionView()
        view?.configureDataSource()
        view?.configureViews()
    }
    
    func finish() {
        coordinator?.finishFlow?()
    }
    
    func getCartItems() {
        guard let userId = SettingsService.sharedInstance.userId else { return }
        service?.fetchItemsCart(userId: userId, completion: { [weak self] result in
            switch result {
            case .success(let items):
                self?.view?.insertItems(items: items)
                self?.setTotalPrice(items: items)
            case .failure(let error):
                debugPrint(error)
            }
        })
    }
    
    func getItem(id: String, completion: @escaping (Item) -> ()) {
        service?.fetchItem(by: id, completion: { result in
            switch result {
            case .success(let item):
                completion(item)
            case .failure(let error):
                debugPrint(error)
            }
        })
    }
    
    func setTotalPrice(items: [Cart]) {
        let totalPrice = items.reduce(0) { partialResult, cartItem in
            return partialResult + cartItem.selectedPrice
        }
        
        self.view?.setTotalPrice(price: totalPrice)
    }
    
    func removeItem(item: Cart) {
        guard let userId = SettingsService.sharedInstance.userId else {
            return
        }
        
        service?.removeItemCart(userId: userId, cartItem: item, completion: { error in
            guard error == nil else { fatalError("\(error!)") }
        })
    }
    
    func createOrder() {
        guard let userId = SettingsService.sharedInstance.userId,
              let itemsInCart = view?.getItemsCart() else {
            return
        }
        
        userService?.fetchUserData(by: userId, completion: { result in
            switch result {
            case .success(_):
                break
            case .failure(let error):
                print(error)
            }
        })
        
    }
}
