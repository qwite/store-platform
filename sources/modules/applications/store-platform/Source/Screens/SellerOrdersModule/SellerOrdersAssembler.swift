import UIKit

// MARK: - SellerOrdersAssembler
class SellerOrdersAssembler {
    static func buildSellerOrdersModule(coordinator: SellerCoordinator) -> UIViewController {
        let service = BrandService()
        let view = SellerOrdersViewController()
        let presenter = SellerOrdersPresenter(view: view, coordinator: coordinator, service: service)
        view.presenter = presenter
        return view
    }
}
