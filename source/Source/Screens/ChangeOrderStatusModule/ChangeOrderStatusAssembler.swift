import UIKit

// MARK: - ChangeOrderStatusAssembler
class ChangeOrderStatusAssembler {
    static func buildChangeOrderStatusModule(coordinator: SellerCoordinator, order: Order) -> UIViewController {
        let service = BrandService()
        let view = ChangeOrderStatusViewController()
        let presenter = ChangeOrderStatusPresenter(view: view, coordinator: coordinator, service: service, order: order)
        view.presenter = presenter
        return view
    }
}
