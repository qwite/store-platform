import Foundation

protocol DetailedAdPresenterProtocol {
    init(view: DetailedAdViewProtocol, coordinator: FeedCoordinator, item: Item, service: UserServiceProtocol)
    func viewDidLoad()
    func showSizePicker()
    func didAddToCart(item: CartItem)
    func createConversation()
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
                debugPrint("view add")
                self.view?.showSuccessAlert()
            case .failure(let error):
                debugPrint(error)
            }
        })
    }
}


