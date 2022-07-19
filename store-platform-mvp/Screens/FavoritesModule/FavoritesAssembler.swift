import UIKit

// MARK: - FavoritesAssembler
class FavoritesAssembler {
    static func buildFavoritesModule(coordinator: FavoritesCoordinator) -> UIViewController {
        let service = FavoritesService()
        let cartService = CartService()
        let view = FavoritesViewController()
        let presenter = FavoritesPresenter(view: view, coordinator: coordinator, service: service, cartService: cartService)
        view.presenter = presenter
        return view
    }
}
