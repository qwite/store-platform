import UIKit

class CartCoordinator: Coordinator {
    var navigationController: UINavigationController
    
    func start() {
        let module = CartAssembler.buildCartModule()
        
        self.navigationController.pushViewController(module, animated: true)
    }
    
    
    required init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
}
