import UIKit

// MARK: - ProfileAssembler
class ProfileAssembler {
    static func buildProfileModule(coordinator: ProfileCoordinator) -> UIViewController {
        let service = UserService()
        let view = ProfileViewController()
        let presenter = ProfilePresenter(view: view, service: service, coordinator: coordinator)
        view.presenter = presenter
        return view
    }
}
