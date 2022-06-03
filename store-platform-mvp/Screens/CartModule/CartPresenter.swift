import Foundation

protocol CartPresenterProtocol {
    init(view: CartViewProtocol)
    func viewDidLoad()
}

class CartPresenter: CartPresenterProtocol {
    weak var view: CartViewProtocol?
    
    required init(view: CartViewProtocol) {
        self.view = view
    }
    
    func viewDidLoad() {
        view?.configureCollectionView()
        view?.configureDataSource()
        view?.configureViews()
    }
}
