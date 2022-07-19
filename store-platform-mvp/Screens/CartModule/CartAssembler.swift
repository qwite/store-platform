import UIKit

// MARK: - CartAssembler
class CartAssembler {
    static func buildCartModule() -> UIViewController {
        let service = CartService()
        let userService = UserService()
        let view = CartViewController()
        let presenter = CartPresenter(view: view, service: service, userService: userService)
        view.presenter = presenter
        return view
    }
}

