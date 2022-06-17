import UIKit

class FavoritesCoordinator: BaseCoordinator, Coordinator {
    var navigationController: UINavigationController
    var factory: Factory?
    
    var completionHandler: ((CartItem) -> ())?
    var childCoordinator =  [Coordinator]()
    
    func start() {
        let module = factory?.buildFavoritesModule(coordinator: self)
        guard let module = module else {
            fatalError()
        }
        
        self.navigationController.pushViewController(module, animated: true)
    }
    
    required init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.factory = DependencyFactory()
    }
    
    // TODO: remove from arc
    func showDetailedAd(with item: Item) {
        let feedCoordinator = FeedCoordinator(self.navigationController)
        self.addDependency(feedCoordinator)
        feedCoordinator.showDetailedAd(with: item)
    }
}

extension FavoritesCoordinator: PickSizeCoordinatorProtocol {
    func showSizePicker(for item: Item) {
        guard let module = factory?.buildSizePickerModule(coordinator: self, item: item) else {
            return
        }
        
        self.navigationController.present(module, animated: true)
    }
    
    func hideSizePicker(with item: CartItem) {
        self.navigationController.dismiss(animated: true) { [weak self] in
            self?.completionHandler?(item)
        }
    }
}
