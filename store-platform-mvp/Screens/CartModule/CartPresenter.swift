import Foundation

protocol CartPresenterProtocol {
    init(view: CartViewProtocol)
}

class CartPresenter: CartPresenterProtocol {
    weak var view: CartViewProtocol?
    
    required init(view: CartViewProtocol) {
        self.view = view
    }
}
