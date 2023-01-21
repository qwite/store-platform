import UIKit

// MARK: - RegisterAssembler
class RegisterAssembler {
    static func buildRegisterModule(coordinator: GuestCoordinator) -> UIViewController {
        let service = UserService()
        let view = RegisterViewController()
        let presenter = RegisterPresenter(view: view, coordinator: coordinator, service: service)
        view.presenter = presenter
        return view
    }
}
