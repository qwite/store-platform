import Foundation

// MARK: - UserOrdersPresenterProtocol
protocol UserOrdersPresenterProtocol {
    init(view: UserOrdersViewProtocol, coordinator: ProfileCoordinator, service: UserServiceProtocol)
    func viewDidLoad()
    func fetchItems()
    func showDetailed(with order: Order)
}

// MARK: - UserOrdersPresenterProtocol Implementation
class UserOrdersPresenter: UserOrdersPresenterProtocol {
    weak var view: UserOrdersViewProtocol?
    weak var coordinator: ProfileCoordinator?
    var service: UserServiceProtocol?
    
    required init(view: UserOrdersViewProtocol, coordinator: ProfileCoordinator, service: UserServiceProtocol) {
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
        guard let userId = SettingsService.sharedInstance.userId else { return }
        service?.fetchUserOrders(by: userId, completion: { [weak self] result in
            switch result {
            case .success(let orders):
                self?.view?.insertItems(items: orders)
            case .failure(_):
                self?.view?.showErrorAlert()
                self?.coordinator?.backToRoot()
            }
        })
    }
    
    func showDetailed(with order: Order) {
        coordinator?.showDetailedOrder(order: order)
    }
}
