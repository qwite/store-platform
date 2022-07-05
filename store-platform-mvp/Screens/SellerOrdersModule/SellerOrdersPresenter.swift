import Foundation

protocol SellerOrdersPresenterProtocol {
    init(view: SellerOrdersViewProtocol, coordinator: SellerCoordinator)
    func viewDidLoad()
    func showChangeStatus(order: Order)
}

class SellerOrdersPresenter: SellerOrdersPresenterProtocol {
    weak var view: SellerOrdersViewProtocol?
    weak var coordinator: SellerCoordinator?
    
    required init(view: SellerOrdersViewProtocol, coordinator: SellerCoordinator) {
        self.view = view
        self.coordinator = coordinator
    }
    
    func viewDidLoad() {
        view?.configureCollectionView()
        view?.configureDataSource()
        view?.configureViews()
        
        fetchItems()
        
    }
    
    func fetchItems() {
        guard let brandName = SettingsService.sharedInstance.brandName else { return }
        
        FirestoreService.sharedInstance.getBrandIdByName(brandName: brandName) { result in
            switch result {
            case .success(let brandId):
                
                FirestoreService.sharedInstance.getBrandOrders(brandId: brandId) { [weak self] result in
                    switch result {
                    case .success(let orders):
                        self?.view?.insertItems(items: orders)
                    case .failure(_):
                        self?.view?.showErrorAlert()
                    }
                }
                
            case .failure(let error):
                fatalError("\(error)")
            }
        }
    }
    
    func showChangeStatus(order: Order) {
        coordinator?.changeOrderStatus(order: order)
    }
    
}
