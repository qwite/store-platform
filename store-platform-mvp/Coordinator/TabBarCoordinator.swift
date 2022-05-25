import UIKit

class TabBarCoordinator: Coordinator {
    var navigationController: UINavigationController?
    private var factory: Factory
    var childCoordinators: [Coordinator] = []
    
    init() {
        self.factory = DependencyFactory()
        childCoordinators.append(AdsListCoordinator(factory: factory))
        childCoordinators.append(CreateAdCoordinator(factory: factory))
    }
    
    func start(_ navigationController: UINavigationController) {
      
    }
}
