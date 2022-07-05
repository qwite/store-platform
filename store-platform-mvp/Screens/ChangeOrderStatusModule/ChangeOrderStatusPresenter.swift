import Foundation

protocol ChangeOrderStatusPresenterProtocol {
    init(view: ChangeOrderStatusViewProtocol, coordinator: SellerCoordinator, order: Order)
    func viewDidLoad()
    
    func getAvailableStatus() -> [String]
    func changeStatus(status: String)
    
}

class ChangeOrderStatusPresenter: ChangeOrderStatusPresenterProtocol {
    weak var view: ChangeOrderStatusViewProtocol?
    weak var coordinator: SellerCoordinator?
    var order: Order
    var availableStatus = ["В обработке", "Отправлен", "Доставлен"]
    
    required init(view: ChangeOrderStatusViewProtocol, coordinator: SellerCoordinator, order: Order) {
        self.view = view
        self.coordinator = coordinator
        self.order = order
    }
    
    func viewDidLoad() {
        view?.configure()
        view?.configureButtons()
    }
    
    func getAvailableStatus() -> [String] {
        return self.availableStatus
    }
    
    // omg shit code
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
        
        FirestoreService.sharedInstance.changeOrderStatus(orderId: id, status: finalStatus) { [weak self] error in
            guard error == nil else { fatalError("\(error!)") }
            
            self?.coordinator?.hideOrderStatus()
        }
    }
    
}
