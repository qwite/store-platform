import Foundation

// MARK: - ChangeOrderStatusPresenterProtocol
protocol ChangeOrderStatusPresenterProtocol {
    init(view: ChangeOrderStatusViewProtocol, coordinator: SellerCoordinator, service: BrandServiceProtocol, order: Order)
    func viewDidLoad()
    
    func getAvailableStatus() -> [String]
    func changeStatus(status: String)
    
}

// MARK: - ChangeOrderStatusPresenterProtocol Implementation
class ChangeOrderStatusPresenter: ChangeOrderStatusPresenterProtocol {
    weak var view: ChangeOrderStatusViewProtocol?
    weak var coordinator: SellerCoordinator?
    var service: BrandServiceProtocol?
    
    var order: Order
    var availableStatus = ["В обработке", "Отправлен", "Доставлен"]
    
    required init(view: ChangeOrderStatusViewProtocol, coordinator: SellerCoordinator, service: BrandServiceProtocol, order: Order) {
        self.view = view
        self.coordinator = coordinator
        self.service = service
        self.order = order
    }
    
    func viewDidLoad() {
        view?.configure()
        view?.configureButtons()
    }
    
    func getAvailableStatus() -> [String] {
        return self.availableStatus
    }
    
    // TODO: Refactor
    func changeStatus(status: String) {
        guard let id = order.id else { return }
        let finalStatus: Order.Status?
        
        switch status {
        case "В обработке":
            finalStatus = .process
        case "Отправлен":
            finalStatus = .shipped
        case "Доставлен":
            finalStatus = .delivered
        default:
            return
        }
        
        guard let finalStatus = finalStatus else {
            return
        }
        
        service?.changeOrderStatus(orderId: id, status: finalStatus) { [weak self] error in
            guard error == nil else { fatalError("\(error!)") }
            
            self?.coordinator?.hideOrderStatus()
        }
    }
    
}
