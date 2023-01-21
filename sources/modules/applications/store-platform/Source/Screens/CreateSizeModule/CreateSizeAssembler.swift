import UIKit

// MARK: - CreateSizeAssembler
class CreateSizeAssembler {
    static func buildCreateSizeModule(coordinator: CreateAdCoordinator, model: Size?) -> UIViewController {
        let view = CreateSizeViewController()
        let presenter = CreateSizePresenter(view: view, coordinator: coordinator, model: model)
        view.presenter = presenter
        return view
    }
}
