import UIKit

class AppCoordinator: Coordinator {
    var navigationController: UINavigationController
    
    var childCoordinator = [Coordinator]()
    
    required init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let tabCoordinator = TabCoordinator(navigationController)
        tabCoordinator.start()
        childCoordinator.append(tabCoordinator)
    }
}
