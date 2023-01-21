import Foundation

// MARK: - DetailedOrderPresenterProtocol
protocol DetailedOrderPresenterProtocol {
    init(view: DetailedOrderViewProtocol, order: Order, coordinator: ProfileCoordinator, service: UserServiceProtocol)
    func viewDidLoad()
    
    func contactWithBrand()
    func addReview(text: String, rating: Double)
}

// MARK: - DetailedOrderPresenterProtocol Implementation
class DetailedOrderPresenter: DetailedOrderPresenterProtocol {
    weak var view: DetailedOrderViewProtocol?
    weak var coordinator: ProfileCoordinator?
    var service: UserServiceProtocol?
    
    var order: Order
    
    required init(view: DetailedOrderViewProtocol, order: Order, coordinator: ProfileCoordinator, service: UserServiceProtocol) {
        self.view = view
        self.order = order
        self.coordinator = coordinator
        self.service = service
    }
    
    func viewDidLoad() {
        self.view?.configure(order: self.order)
        self.view?.configureButtons()
    }
    
    func contactWithBrand() {
        coordinator?.hideDetailedOrder(brandId: order.brandId)
    }
    
    func addReview(text: String, rating: Double) {
        guard let userId = SettingsService.sharedInstance.userId,
              let fullName = SettingsService.sharedInstance.userFullName,
              let firstName = fullName["firstName"] else { return }
        
        let itemId = order.item.itemId
        let review = Review(text: text, rating: rating, userFirstName: firstName, userId: userId)
        
        service?.addReviewItem(by: itemId, review: review, completion: { [weak self] error in
            guard error == nil else {
                self?.view?.showError(); return
            }
            
            self?.view?.showSuccess()
        })
    }
}
