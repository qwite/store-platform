import UIKit

// MARK: - CartAssembler
class CartAssembler {
    static func buildCartModule(coordinator: CartCoordinator) -> UIViewController {
        let service = CartService()
        let userService = UserService()
        let view = CartViewController()
        let presenter = CartPresenter(view: view, service: service, userService: userService, coordinator: coordinator)
        view.presenter = presenter
        return view
    }
}

