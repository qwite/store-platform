import Foundation

protocol DetailedOrderPresenterProtocol {
    init(view: DetailedOrderViewProtocol, order: Order, coordinator: ProfileCoordinator)
    func viewDidLoad()
    
    func configure()
    func contactWithBrand()
    func addReview(text: String, rating: Double)
}

class DetailedOrderPresenter: DetailedOrderPresenterProtocol {
    weak var view: DetailedOrderViewProtocol?
    weak var coordinator: ProfileCoordinator?
    var order: Order
    
    required init(view: DetailedOrderViewProtocol, order: Order, coordinator: ProfileCoordinator) {
        self.view = view
        self.order = order
        self.coordinator = coordinator
    }
    
    func viewDidLoad() {
        self.configure()
    }
    
    func configure() {
        self.view?.configure(order: self.order)
        self.view?.configureButtons()
    }
    
    func contactWithBrand() {
        coordinator?.hideDetailedOrder(brandId: order.brandId)
    }
    
    func addReview(text: String, rating: Double) {
        guard let userId = SettingsService.sharedInstance.userId,
              let fullName = SettingsService.sharedInstance.userFullName,
              let firstName = fullName["firstName"]    else { return }
        
        let review = Review(text: text, rating: rating, userFirstName: firstName, userId: userId)
        
        
        FirestoreService.sharedInstance.addReviewToItem(itemId: self.order.item.itemId, review: review) { [weak self] error in
            guard error == nil else { self?.view?.showError(); return }
            
            self?.view?.showSuccess()
        }
    }
    
    
}
