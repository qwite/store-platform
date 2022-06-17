import Foundation

protocol CartPresenterProtocol {
    init(view: CartViewProtocol, service: UserServiceProtocol)
    func viewDidAppear()
    func viewDidLoad()
    
    func getCartItems()
    func setTotalPrice(items: [CartItem])
    func removeItem(item: CartItem)
}

class CartPresenter: CartPresenterProtocol {
    weak var view: CartViewProtocol?
    var service: UserServiceProtocol?
    
    required init(view: CartViewProtocol, service: UserServiceProtocol) {
        self.view = view
        self.service = service
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
    
    func getCartItems() {
        service?.getItemsFromCart(completion: { [weak self] result in
            switch result {
            case .success(let items):
                self?.view?.insertItems(items: items)
                self?.setTotalPrice(items: items)
            case .failure(let error):
                debugPrint(error)
            }
        })
    }
    
    func setTotalPrice(items: [CartItem]) {
        let totalPrice = items.reduce(0) { partialResult, cartItem in
            return partialResult + cartItem.selectedPrice
        }
        
        self.view?.setTotalPrice(price: totalPrice)
    }
    
    func removeItem(item: CartItem) {
        guard let userId = SettingsService.sharedInstance.userId else {
            return
        }
        
        FirestoreService.sharedInstance.removeItemFromCart(userId: userId, selectedItem: item) { error in
            guard error == nil else {
                fatalError("\(error!)")
            }
            
        }
    }
}
