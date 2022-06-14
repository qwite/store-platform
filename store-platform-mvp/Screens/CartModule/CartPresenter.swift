import Foundation

protocol CartPresenterProtocol {
    init(view: CartViewProtocol, service: UserServiceProtocol)
    func viewDidLoad()
    func getCartItems()
}

class CartPresenter: CartPresenterProtocol {
    weak var view: CartViewProtocol?
    var service: UserServiceProtocol?
    
    required init(view: CartViewProtocol, service: UserServiceProtocol) {
        self.view = view
        self.service = service
    }
    
    func viewDidLoad() {
        view?.configureCollectionView()
        view?.configureDataSource()
        view?.configureViews()
        
        getCartItems()
    }
    
    func getCartItems() {
        service?.getItemsFromCart(completion: { [weak self] result in
            switch result {
            case .success(let items):
                self?.view?.insertItems(items: items)
            case .failure(let error):
                debugPrint(error)
            }
        })
    }
}
