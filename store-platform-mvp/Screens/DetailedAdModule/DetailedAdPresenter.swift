import Foundation

protocol DetailedAdPresenterProtocol {
    init(view: DetailedAdViewProtocol, coordinator: FeedCoordinator, item: Item, service: UserServiceProtocol)
    func viewDidLoad()
    
    func increaseItemViews()
    func showSizePicker()
    func didAddToCart(item: CartItem)
    func createConversation()
    func getReviews()
    func addToSubscriptions()
}

class DetailedAdPresenter: DetailedAdPresenterProtocol {
    weak var view: DetailedAdViewProtocol?
    weak var coordinator: FeedCoordinator?
    var service: UserServiceProtocol?
    
    var item: Item
    
    required init(view: DetailedAdViewProtocol, coordinator: FeedCoordinator, item: Item, service: UserServiceProtocol) {
        self.view = view
        self.coordinator = coordinator
        self.item = item
        self.service = service
    }
    
    func viewDidLoad() {
        view?.configure(with: item)
        increaseItemViews()
        getReviews()
    }
    
    func increaseItemViews() {
        guard let itemId = item.id else { return }
        
        service?.increaseItemViews(itemId: itemId, completion: { result in
            switch result {
            case .success(let message):
                debugPrint(message)
            case .failure(let error):
                debugPrint(error)
            }
        })
    }
    
    func createConversation() {
        FirestoreService.sharedInstance.getBrandIdByName(brandName: item.brandName) { [weak self] result in
            switch result {
            case .success(let brandId):
                self?.coordinator?.showMessenger(conversationId: nil, brandId: brandId)
            case .failure(let error):
                fatalError("\(error)")
            }
        }
    }
    
    func getReviews() {
        guard let id = item.id else { fatalError() }
        
        FirestoreService.sharedInstance.getReviewsFromItem(itemId: id) { [weak self] result in
            switch result {
            case .success(let reviews):
                self?.view?.configureReviews(reviews: reviews)
            case .failure(let error):
                debugPrint(error)
                self?.view?.configureReviews(reviews: nil)
            }
        }
    }
    
    func showSizePicker() {        
        coordinator?.showSizePicker(for: item)
        coordinator?.completionHandler = { item in
            self.didAddToCart(item: item)
        }
    }
    
    func didAddToCart(item: CartItem) {
        service?.addItemToCart(item: item, completion: { result in
            switch result {
            case .success(_):
                self.view?.showSuccessAlert(message: "Товар в корзине!")
            case .failure(let error):
                debugPrint(error)
            }
        })
    }
    
    func addToSubscriptions() {
        guard let userId = SettingsService.sharedInstance.userId else { return }
        let brandName = item.brandName
        
        FirestoreService.sharedInstance.getBrandIdByName(brandName: item.brandName) { result in
            switch result {
            case .success(let brandId):
                FirestoreService.sharedInstance.addToSubscriptions(userId: userId, brandId: brandId, brandName: brandName) { [weak self] error in
                    guard error == nil else { print(error!); return}
                    
                    self?.view?.showSuccessAlert(message: "Бренд добавлен в подписки")
                }

            case .failure(let error):
                fatalError("\(error)")
            }
        }
    }
}


