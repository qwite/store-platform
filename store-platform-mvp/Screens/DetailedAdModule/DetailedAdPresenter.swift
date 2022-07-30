import Foundation

// MARK: - DetailedAdPresenterProtocol
protocol DetailedAdPresenterProtocol {
    init(view: DetailedAdViewProtocol,
         coordinator: FeedCoordinator,
         item: Item,
         service: FeedServiceProtocol,
         cartService: CartServiceProtocol,
         userService: UserServiceProtocol)
    
    func viewDidLoad()
    func finish()
    
    func increaseViews()
    func showSizePicker()
    func didAddToCart(item: Cart)
    func createConversation()
    func getReviews()
    func getCurrentDay() -> MonthlyViews?
    func addToSubscriptions()
}

// MARK: - DetailedAdPresenterProtocol Implementation
class DetailedAdPresenter: DetailedAdPresenterProtocol {
    
    required init(view: DetailedAdViewProtocol, coordinator: FeedCoordinator, item: Item, service: FeedServiceProtocol, cartService: CartServiceProtocol, userService: UserServiceProtocol) {
        self.view = view
        self.coordinator = coordinator
        self.item = item
        
        self.service = service
        self.cartService = cartService
        self.userService = userService
    }
    
    weak var view: DetailedAdViewProtocol?
    weak var coordinator: FeedCoordinator?
    
    var service: FeedServiceProtocol?
    var cartService: CartServiceProtocol?
    var userService: UserServiceProtocol?
    
    var item: Item
    
    func viewDidLoad() {
        view?.configure(with: item)
        increaseViews()
        getReviews()
    }
    
    func finish() {
        coordinator?.finishFlow?()
    }
    
    func increaseViews() {
        guard let currentDay = getCurrentDay() else { return }
        service?.increaseItemViews(item: item, views: currentDay, completion: { error in
            guard error == nil else { return }
        })
    }
    
    func getCurrentDay() -> MonthlyViews? {
        guard let currentDay = DateFormatter.getDay() else { return nil }
        let currentMonth = DateFormatter.getMonth()
        
        let views = MonthlyViews(month: currentMonth, day: currentDay)
        return views
    }
    
    // Asking a question to brand.
    func createConversation() {
        FirestoreService.sharedInstance.getBrandIdByName(brandName: item.brandName) { [weak self] result in
            switch result {
            case .success(let brandId):
                self?.coordinator?.showMessenger(brandId: brandId)
            case .failure(let error):
                fatalError("\(error)")
            }
        }
    }
    
    func getReviews() {
        service?.fetchItemReviews(item: item, completion: { [weak self] result in
            switch result {
            case .success(let reviews):
                self?.view?.configureReviews(reviews: reviews)
            case .failure(_):
                self?.view?.configureReviews(reviews: nil)
            }
        })
    }
    
    func showSizePicker() {        
        coordinator?.showSizePicker(for: item)
        coordinator?.completionHandler = { item in
            self.didAddToCart(item: item)
        }
    }
    
    func didAddToCart(item: Cart) {
        guard let userId = SettingsService.sharedInstance.userId else { return }
        cartService?.addItemCart(userId: userId, cartItem: item, completion: { [weak self] result in
            switch result {
            case .success(_):
                self?.view?.showSuccessAlert(message: Constants.Messages.successAddCart)
            case .failure(let error):
                fatalError("\(error)")
            }
        })
    }
    
    func addToSubscriptions() {
        guard let userId = SettingsService.sharedInstance.userId else { return }
        let brandName = item.brandName
        
        FirestoreService.sharedInstance.getBrandIdByName(brandName: item.brandName) { [weak self] result in
            switch result {
            case .success(let brandId):
                self?.service?.addSubscription(userId: userId, brandId: brandId, brandName: brandName) { [weak self] error in
                    guard error == nil else { print(error!); return}
                    
                    self?.view?.showSuccessAlert(message: Constants.Messages.successAddSubscription)
                }
            case .failure(let error):
                fatalError("\(error)")
            }
        }
    }
}


