import Foundation

protocol DetailedAdPresenterProtocol {
    init(view: DetailedAdViewProtocol, coordinator: PickSizeCoordinatorProtocol, item: Item) 
    func viewDidLoad()
    func showSizePicker()
}

class DetailedAdPresenter: DetailedAdPresenterProtocol {
    weak var view: DetailedAdViewProtocol?
    weak var coordinator: PickSizeCoordinatorProtocol?
    var item: Item
    
    required init(view: DetailedAdViewProtocol, coordinator: PickSizeCoordinatorProtocol, item: Item) {
        self.view = view
        self.coordinator = coordinator
        self.item = item
    }
    
    func viewDidLoad() {
        view?.configure(with: item)
    }
    
    func showSizePicker() {
        guard let sizes = item.sizes else {
            return
        }
        
        coordinator?.showSizePicker(with: sizes)
        coordinator?.completionHandler = { [weak self] size in
            self?.didSelectSize(selectedSize: size)
        }
    }
    
    func didSelectSize(selectedSize: Size) {
        guard let size = selectedSize.size else {
            return
        }
        
        FirestoreService.sharedInstance.addItemToCart(selectedSize: size, item: self.item) { [weak self] result in
            switch result {
            case .success(_):
                self?.view?.showSuccessAlert()
            case .failure(let error):
                debugPrint(error)
            }
        }
    }
    
}


