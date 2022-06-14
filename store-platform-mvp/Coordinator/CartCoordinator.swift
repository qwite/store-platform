import UIKit

class CartCoordinator: Coordinator {
    var navigationController: UINavigationController
    var factory: Factory?
    
    func start() {
        guard let module = factory?.buildCartModule() else {
            return
        }
         self.navigationController.pushViewController(module, animated: false)
    }
    
    
    required init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.factory = DependencyFactory()
    }
}
