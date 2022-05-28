import UIKit

class ProfileCoordinator: Coordinator {
    var navigationController: UINavigationController
    var factory: Factory?
    var childCoordinator = [Coordinator]()
    
    func start() {
        guard let module = factory?.buildProfileModule() else {
            return
        }
        
        self.navigationController.pushViewController(module, animated: true)
    }
    
    required init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.factory = DependencyFactory()
    }
}
