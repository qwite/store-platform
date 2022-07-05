import Foundation

protocol CartPresenterProtocol {
    init(view: CartViewProtocol, service: UserServiceProtocol)
    func viewDidAppear()
    func viewDidLoad()
    
    func setTotalPrice(items: [CartItem])
    func removeItem(item: CartItem)
    func createOrder()
}

class CartPresenter: CartPresenterProtocol {
    weak var view: CartViewProtocol?
    var service: UserServiceProtocol?
    
    // TODO: make more safety
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        formatter.timeZone = .current
        formatter.locale = Locale(identifier: "en_GB")
        return formatter
    }()
    
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
    
    func createOrder() {
        guard let userId = SettingsService.sharedInstance.userId,
              let items = view?.getItemsInCart() else { return }
        let currentDateString = dateFormatter.string(from: Date())
        let group = DispatchGroup()
        var counter = 0
        for item in items {
            group.enter()
            FirestoreService.sharedInstance.createOrder(userId: userId, item: item, date: currentDateString) { error in
                defer { group.leave() }
                
                guard error == nil else { fatalError("\(error!)") }
                
                print("order created")
                counter += 1
            }
        }
        
        // update cart
        group.notify(queue: .main) {
            if counter == items.count {
                print("updating cart..")
                self.getCartItems()
            }
        }
    }
}
