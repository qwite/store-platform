import UIKit

// MARK: - DetailedAdAssembler
class DetailedAdAssembler {
    static func buildDetailedAd(coordinator: FeedCoordinator, item: Item) -> UIViewController {
        let service = FeedService()
        let cartService = CartService()
        let userService = UserService()
        let view = DetailedAdViewController()
        let presenter = DetailedAdPresenter(view: view,
                                            coordinator: coordinator,
                                            item: item,
                                            service: service,
                                            cartService: cartService,
                                            userService: userService)
        view.presenter = presenter
        return view
    }
 }
