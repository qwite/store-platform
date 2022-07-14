import UIKit

class CartAssembler {
    static func buildCartModule() -> UIViewController {
        let service = CartService()
        let view = CartViewController()
        let presenter = CartPresenter(view: view, service: service)
        view.presenter = presenter
        return view
    }
}

