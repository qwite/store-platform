import UIKit

class FavoritesCoordinator: Coordinator {
    var navigationController: UINavigationController
    var factory: Factory?
    
    var completionHandler: ((Size) -> ())?
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
    
    func showDetailedAd(with item: Item) {
        guard let module = factory?.buildDetailedAdModule(coordinator: self, with: item) else {
            return
        }
        
        self.navigationController.pushViewController(module, animated: true)
    }
}

extension FavoritesCoordinator: PickSizeCoordinatorProtocol {
    func showSizePicker(with sizes: [Size]) {
        guard let module = factory?.buildSizePickerModule(coordinator: self, sizes: sizes) else {
            return
        }
        
        self.navigationController.present(module, animated: true)
    }
    
    func hideSizePicker(with size: Size) {
        self.navigationController.dismiss(animated: true) { [weak self] in
            self?.completionHandler?(size)
        }
    }
}
