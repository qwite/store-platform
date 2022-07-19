import Foundation

// MARK: - SellerOrdersPresenterProtocol
protocol SellerOrdersPresenterProtocol {
    init(view: SellerOrdersViewProtocol, coordinator: SellerCoordinator, service: BrandServiceProtocol)
    func viewDidLoad()
    func showChangeStatus(order: Order)
}

// MARK: - SellerOrdersPresenterProtocol Implementation
class SellerOrdersPresenter: SellerOrdersPresenterProtocol {
    weak var view: SellerOrdersViewProtocol?
    weak var coordinator: SellerCoordinator?
    var service: BrandServiceProtocol?
    
    required init(view: SellerOrdersViewProtocol, coordinator: SellerCoordinator, service: BrandServiceProtocol) {
        self.view = view
        self.coordinator = coordinator
        self.service = service
    }
    
    func viewDidLoad() {
        view?.configureCollectionView()
        view?.configureDataSource()
        view?.configureViews()
        
        fetchItems()
    }
    
    func fetchItems() {
        guard let brandName = SettingsService.sharedInstance.brandName else { return }
        service?.getBrandIdByName(brandName: brandName, completion: { [weak self] result in
            switch result {
            case .success(let brandId):
                self?.service?.fetchOrders(brandId: brandId, completion: { result in
                    switch result {
                    case .success(let orders):
                        self?.view?.insertItems(items: orders)
                    case .failure(_):
                        self?.view?.showErrorAlert()
                    }
                })
            case .failure(_):
                self?.view?.showErrorAlert()
            }
        })
    }
    
    func showChangeStatus(order: Order) {
        coordinator?.changeOrderStatus(order: order)
    }
    
}
