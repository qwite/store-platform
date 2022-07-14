import UIKit

// MARK: - FavoritesAssembler
class FavoritesAssembler {
    static func buildFavoritesModule(coordinator: FavoritesCoordinator) -> UIViewController {
        let service = FavoritesService()
        let view = FavoritesViewController()
        let presenter = FavoritesPresenter(view: view, coordinator: coordinator, service: service)
        view.presenter = presenter
        return view
    }
}
