import UIKit

// MARK: - DetailedProfileAssembler
class DetailedProfileAssembler {
    static func buildDetailedProfileModule(coordinator: ProfileCoordinator) -> UIViewController {
        let service = UserService()
        let view = DetailedProfileViewController()
        let presenter = DetailedProfilePresenter(view: view, coordinator: coordinator, service: service)
        view.presenter = presenter
        return view
    }
}
