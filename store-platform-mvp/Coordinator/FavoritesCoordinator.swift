import UIKit
import LBBottomSheet

// MARK: - FavoritesCoordinator
class FavoritesCoordinator: BaseCoordinator, Coordinator {
    var navigationController: UINavigationController
    var factory: Factory?
    
    var completionHandler: ((Cart) -> ())?
    var childCoordinator =  [Coordinator]()
    
    func start() {
        let module = FavoritesAssembler.buildFavoritesModule(coordinator: self)
        
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
        
        let behavior: BottomSheetController.Behavior = .init(swipeMode: .top)
        self.navigationController.presentAsBottomSheet(module, behavior: behavior)
    }
    
    func hideSizePicker(with item: Cart) {
        
        self.navigationController.dismissBottomSheet { [weak self] in
            self?.completionHandler?(item)
        }
    }
}
