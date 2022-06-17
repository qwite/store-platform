import UIKit
import LBBottomSheet

class FeedCoordinator: NSObject, Coordinator {
    var navigationController: UINavigationController
    var factory: Factory?
    var childCoordinator = [Coordinator]()
    var completionHandler: ((CartItem) -> ())?
    var parent: FeedViewController?
    
    var sortingPresenter: SortingFeedPresenterProtocol?
    var sortingNavigation: UINavigationController?
    
    required init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
        factory = DependencyFactory()
    }
    
    var finish: (() -> ())?
    
    func start() {
        self.showFeed(with: nil)
    }
    
    func showFeed(with items: [Item]?) {
        guard let module = factory?.buildFeedModule(coordinator: self, with: items) as? FeedViewController else {
            return
        }
        
        self.parent = module
        self.navigationController.pushViewController(module, animated: true)
    }
    
    func showSearchFeed() -> UIViewController? {
        guard let module = factory?.buildFeedModule(coordinator: self, with: nil) as? FeedViewController else {
            return nil
        }
        
        return module
    }
    
    func showSortingFeed() {
        guard let parent = self.parent,
              let module = factory?.buildFeedSortingModule(delegate: parent.presenter, coordinator: self) as? SortingFeedViewController else {
            return
        }
        
        self.sortingPresenter = module.presenter
        let navigation = UINavigationController(rootViewController: module)
        self.sortingNavigation = navigation
        
        self.navigationController.presentAsBottomSheet(navigation)
    }
    
    func hideSortingFeed() {
        guard let sortingNavigation = sortingNavigation else {
            fatalError()
        }
        
        sortingNavigation.dismiss(animated: true)
    }
    
    func showColorParameters() {
        guard let navigation = sortingNavigation,
              let sortingPresenter = self.sortingPresenter,
              let module = factory?.buildAvailableParametersModule(delegate: sortingPresenter, type: .color) else {
            return
        }
        
        navigation.pushViewController(module, animated: true)
    }
    
    func showSizeParameters() {
        guard let navigation = sortingNavigation,
              let sortingPresenter = self.sortingPresenter,
              let module = factory?.buildAvailableParametersModule(delegate: sortingPresenter, type: .size) else {
            return
        }
        
        navigation.pushViewController(module, animated: true)
    }
    
    func showDetailedAd(with item: Item) {
        guard let module = factory?.buildDetailedAdModule(coordinator: self, with: item) else {
            return
        }
        
        self.navigationController.pushViewController(module, animated: true)
    }
    
    func showSearchScreen() {
        guard let module = factory?.buildSearchModule(coordinator: self) else {
            return
        }
        
        self.navigationController.pushViewController(module, animated: true)
    }
    
}

extension FeedCoordinator: PickSizeCoordinatorProtocol {
    func showSizePicker(for item: Item) {
        guard let module = factory?.buildSizePickerModule(coordinator: self, item: item) else {
            return
        }
        
        self.navigationController.present(module, animated: true)
    }
    
    func hideSizePicker(with item: CartItem) {
        self.navigationController.dismiss(animated: true) {
            self.completionHandler?(item)
        }
        self.navigationController.popViewController(animated: true)
    }
}

extension FeedCoordinator: MessagesCoordinatorProtocol {
    func showListMessages() {
        
    }
    
    func showMessenger(conversationId: String?, brandId: String?) {
        guard let module = factory?.buildMessengerModule(conversationId: nil, brandId: brandId, coordinator: self) else {
            fatalError()
        }
        
        self.navigationController.pushViewController(module, animated: true)
    }
    
    func showImagePicker() {
        
    }
    
    func showImageDetail(image: Data) {
        
    }
}

