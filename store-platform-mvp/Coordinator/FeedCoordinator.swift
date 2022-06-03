import UIKit

class FeedCoordinator: Coordinator {
    var navigationController: UINavigationController
    var factory: Factory?
    var childCoordinator = [Coordinator]()
    
    var completionHandler: ((Size) -> ())?

    
    required init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
        factory = DependencyFactory()
    }
    
    var finish: (() -> ())?
    
    func start() {
        guard let module = factory?.buildFeedModule(coordinator: self) else {
            return
        }
        
        self.navigationController.pushViewController(module, animated: false)
    }
    
    func showDetailedAd(with item: Item) {
        guard let module = factory?.buildDetailedAdModule(coordinator: self, with: item) else {
            return
        }
        
        self.navigationController.pushViewController(module, animated: true)
    }
}

extension FeedCoordinator: PickSizeCoordinatorProtocol {    
    func showSizePicker(with sizes: [Size]) {
        guard let module = factory?.buildSizePickerModule(coordinator: self, sizes: sizes) else {
            return
        }
        
        self.navigationController.present(module, animated: true)
    }
    
    func hideSizePicker(with size: Size) {
        self.navigationController.dismiss(animated: true) { [weak self] in
            self?.completionHandler?(size)
            self?.navigationController.popViewController(animated: true)
        }
    }
}
