import UIKit
import LBBottomSheet

// MARK: - FavoritesCoordinator
class FavoritesCoordinator: BaseCoordinator, Coordinator {
    var navigationController: UINavigationController
    
    var completionHandler: ((Cart) -> ())?
    
    var childCoordinator =  [Coordinator]()
    
    func start() {
        let module = FavoritesAssembler.buildFavoritesModule(coordinator: self)
        
        self.navigationController.pushViewController(module, animated: true)
    }
    
    required init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func showDetailedAd(with item: Item) {
        let feedCoordinator = FeedCoordinator(self.navigationController)
        self.addDependency(feedCoordinator)
        
        feedCoordinator.finishFlow = { [weak self, weak feedCoordinator] in
            guard let feedCoordinator = feedCoordinator else { return }
            
            self?.removeDependency(feedCoordinator)
        }
        
        feedCoordinator.showDetailedAd(with: item)
    }
}

// MARK: - SizePickerCoordinatorProtocol
extension FavoritesCoordinator: SizePickerCoordinatorProtocol {
    func showSizePicker(for item: Item) {
        let module = SizePickerAssembler.buildSizePickerModule(coordinator: self, with: item)
        
        let behavior: BottomSheetController.Behavior = .init(swipeMode: .top)
        self.navigationController.presentAsBottomSheet(module, behavior: behavior)
    }
    
    func hideSizePicker(with item: Cart) {
        
        self.navigationController.dismissBottomSheet { [weak self] in
            self?.completionHandler?(item)
        }
    }
}
