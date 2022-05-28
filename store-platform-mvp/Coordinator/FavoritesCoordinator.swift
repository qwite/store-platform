import UIKit

class FavoritesCoordinator: Coordinator {
    var navigationController: UINavigationController
    var factory: Factory?
    
    var childCoordinator =  [Coordinator]()
    
    func start() {
        let module = factory?.buildFavoritesModule()
        guard let module = module else {
            fatalError()
        }
        
        self.navigationController.pushViewController(module, animated: true)
    }
    
    required init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.factory = DependencyFactory()
    }
}
