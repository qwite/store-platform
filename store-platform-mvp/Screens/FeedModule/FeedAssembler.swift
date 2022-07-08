import UIKit

// MARK: - FeedAssembler
class FeedAssembler {
    static func buildFeedModule(coordinator: FeedCoordinator,
                                service: FeedServiceProtocol,
                                userService: UserServiceProtocol,
                                items: [Item]?) -> UIViewController {
        let view = FeedViewController()
        let presenter = FeedPresenter(view: view, coordinator: coordinator, service: service, userService: userService, items: items)
        view.presenter = presenter
        return view
    }
}
