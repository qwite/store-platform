import UIKit

// MARK: - DetailedOrderAssembler
class DetailedOrderAssembler {
    static func buildDetailedOrderModule(coordinator: ProfileCoordinator, order: Order) -> UIViewController {
        let service = UserService()
        let view = DetailedOrderViewController()
        let presenter = DetailedOrderPresenter(view: view, order: order, coordinator: coordinator, service: service)
        view.presenter = presenter
        return view
    }
}
