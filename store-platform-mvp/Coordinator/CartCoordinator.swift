import UIKit

class CartCoordinator: Coordinator {
    var navigationController: UINavigationController
    var factory: Factory?
    
    func start() {
        let module = CartAssembler.buildCartModule()
        
        self.navigationController.pushViewController(module, animated: true)
    }
    
    
    required init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.factory = DependencyFactory()
    }
}
