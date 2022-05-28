import UIKit

class FeedCoordinator: Coordinator {
    var navigationController: UINavigationController
    var factory: Factory
    var childCoordinator = [Coordinator]()

    required init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
        factory = DependencyFactory()
    }

    func start() {
        let module = factory.buildFeedModule(coordinator: self)
        self.navigationController.pushViewController(module, animated: false)
    }
}
