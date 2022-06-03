import UIKit

protocol CartViewProtocol: AnyObject {
    
}

class CartViewController: UIViewController {
    var cartView = CartView()
    var presenter: CartPresenter!
    //MARK: - Lifecycle
    
    override func loadView() {
        view = cartView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cartView.configureViews()
    }
}

extension CartViewController: CartViewProtocol {
    
}
