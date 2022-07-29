import UIKit

// MARK: - CreateAdAssembler
class CreateAdAssembler {
    static func buildCreateAdModule(coordinator: CreateAdCoordinator) -> UIViewController {
        let view = CreateAdViewController()
        let service = BrandService()
        let builder = ItemBuilder()
        let presenter = CreateAdPresenter(view: view, itemBuilder: builder, coordinator: coordinator, service: service)
        coordinator.imageDelegate = presenter
        view.presenter = presenter
        return view
    }
}
