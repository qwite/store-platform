import UIKit

// MARK: - GuestAssembler
class GuestAssembler {
    static func buildGuestModule(coordinator: GuestCoordinator) -> UIViewController {
        let view = GuestViewController()
        let presenter = GuestPresenter(view: view, coordinator: coordinator)
        view.presenter = presenter
        return view
    }
}
