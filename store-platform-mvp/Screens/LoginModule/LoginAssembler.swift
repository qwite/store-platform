import UIKit

// MARK: - LoginAssembler
class LoginAssembler {
    static func buildLoginModule(coordinator: GuestCoordinator) -> UIViewController {
        let service = UserService()
        let view = LoginViewController()
        let presenter = LoginPresenter(view: view, coordinator: coordinator, service: service)
        view.presenter = presenter
        return view
    }
}
