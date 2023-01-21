import UIKit

// MARK: - FeedAssembler
class FeedAssembler {
    static func buildFeedModule(coordinator: FeedCoordinator,
                                items: [Item]?) -> UIViewController {
        let userService = UserService()
        let favoritesService = FavoritesService()
        let service = FeedService()
        let view = FeedViewController()
        let presenter = FeedPresenter(view: view,
                                      coordinator: coordinator,
                                      service: service,
                                      userService: userService,
                                      favoritesService: favoritesService,
                                      items: items)
        view.presenter = presenter
        return view
    }
}
