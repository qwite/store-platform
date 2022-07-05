import Foundation

protocol SubscriptionsPresenterProtocol: AnyObject {
    init(view: SubscriptionsViewProtocol, coordinator: ProfileCoordinator)
    func viewDidLoad()
}

class SubscriptionsPresenter: SubscriptionsPresenterProtocol {
    weak var view: SubscriptionsViewProtocol?
    weak var coordinator: ProfileCoordinator?
    
    required init(view: SubscriptionsViewProtocol, coordinator: ProfileCoordinator) {
        self.view = view
        self.coordinator = coordinator
    }
    
    func viewDidLoad() {
        view?.configureCollectionView()
        view?.configureDataSource()
        view?.configureViews()
        
        getSubscriptions()
    }
    
    func getSubscriptions() {
        guard let userId = SettingsService.sharedInstance.userId else { return }
        FirestoreService.sharedInstance.getSubscriptions(userId: userId) { [weak self] result in
            switch result {
            case .success(let subscriptions):
                print(subscriptions)
                self?.view?.insertSubscriptions(items: subscriptions)
            case .failure(let error):
                print(error)
                fatalError()
            }
        }
    }
    
    func removeSubscription(brandName: String) {
        guard let userId = SettingsService.sharedInstance.userId else { return }
        FirestoreService.sharedInstance.removeSubscription(userId: userId, brandName: brandName) { error in
            guard error == nil else { fatalError("\(error!)") }
            
            debugPrint("подписка удалена")
            self.getSubscriptions()
        }
    }
}
