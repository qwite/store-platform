import UIKit

class CartCoordinator: Coordinator {
    var navigationController: UINavigationController
    var finishFlow: (() -> (Void))?
    
    func start() {
        let module = CartAssembler.buildCartModule(coordinator: self)
        
        self.navigationController.pushViewController(module, animated: true)
    }
    
    required init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
}
