import Foundation

// MARK: - SubscriptionsPresenterProtocol
protocol SubscriptionsPresenterProtocol: AnyObject {
    init(view: SubscriptionsViewProtocol, coordinator: ProfileCoordinator, service: UserServiceProtocol)
    func viewDidLoad()
}

// MARK: - SubscriptionsPresenterProtocol
class SubscriptionsPresenter: SubscriptionsPresenterProtocol {
    weak var view: SubscriptionsViewProtocol?
    weak var coordinator: ProfileCoordinator?
    var service: UserServiceProtocol?
    
    required init(view: SubscriptionsViewProtocol, coordinator: ProfileCoordinator, service: UserServiceProtocol) {
        self.view = view
        self.coordinator = coordinator
        self.service = service
    }
    
    func viewDidLoad() {
        view?.configureCollectionView()
        view?.configureDataSource()
        view?.configureViews()
        
        getSubscriptions()
    }
    
    func getSubscriptions() {
        guard let userId = SettingsService.sharedInstance.userId else { return }
        service?.fetchUserSubscriptions(userId: userId) { [weak self] result in
            switch result {
            case .success(let subscriptions):
                print(subscriptions)
                self?.view?.insertSubscriptions(items: subscriptions)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func removeSubscription(brandName: String) {
        guard let userId = SettingsService.sharedInstance.userId else { return }
        service?.removeSubscription(userId: userId, brandName: brandName) { error in
            guard error == nil else { fatalError("\(error!)") }
            
            self.getSubscriptions()
        }
    }
}
