import Foundation

protocol UserOrdersPresenterProtocol {
    init(view: UserOrdersViewProtocol, coordinator: ProfileCoordinator)
    func viewDidLoad()
    func fetchItems()
    func showDetailed(with order: Order)
}

class UserOrdersPresenter: UserOrdersPresenterProtocol {
    weak var view: UserOrdersViewProtocol?
    weak var coordinator: ProfileCoordinator?
    
    required init(view: UserOrdersViewProtocol, coordinator: ProfileCoordinator) {
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
        guard let userId = SettingsService.sharedInstance.userId else { return }
        FirestoreService.sharedInstance.getUserOrders(userId: userId) { [weak self] result in
            switch result {
            case .success(let orders):
                self?.view?.insertItems(items: orders)
            case .failure(let error):
                self?.view?.showErrorAlert()
            }
        }
    }
    
    func showDetailed(with order: Order) {
        coordinator?.showDetailedOrder(order: order)
    }
}
