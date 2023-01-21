import UIKit

// MARK: - UserOrdersAssembler
class UserOrdersAssembler {
    static func buildUserOrdersModule(coordinator: ProfileCoordinator) -> UIViewController {
        let service = UserService()
        let view = UserOrdersViewController()
        let presenter = UserOrdersPresenter(view: view, coordinator: coordinator, service: service)
        view.presenter = presenter
        return view
    }
}
