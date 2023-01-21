import UIKit

class SellerAssembler {
    static func buildSellerModule(coordinator: SellerCoordinator) -> UIViewController {
        let service = BrandService()
        let view = SellerViewController()
        let presenter = SellerPresenter(view: view, coordinator: coordinator, service: service)
        view.presenter = presenter
        return view
    }
}
