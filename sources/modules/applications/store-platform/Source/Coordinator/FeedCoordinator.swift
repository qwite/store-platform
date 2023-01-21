import UIKit
import LBBottomSheet

class FeedCoordinator: BaseCoordinator, Coordinator {
    var navigationController: UINavigationController
    var completionHandler: ((Cart) -> ())?
    var parent: FeedViewController?

    var sortingPresenter: SortingFeedPresenterProtocol?
    var sortingNavigation: UINavigationController?
    
    weak var imageDelegate: ImagePickerDelegate?
    
    required init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    deinit {}
    
    var finishFlow: (() -> (Void))?
    
    func start() {
        showFeed()
    }
    
    func showFeed(with items: [Item]? = nil) {
        guard let module = FeedAssembler.buildFeedModule(coordinator: self, items: items) as? FeedViewController else { return }
        self.parent = module
        self.navigationController.pushViewController(module, animated: true)
    }
    
    func showSearchFeed() -> UIViewController? {
        guard let module = FeedAssembler.buildFeedModule(coordinator: self, items: nil) as? FeedViewController else { return nil }

        return module
    }
    
    func showSortingFeed() {
        let service = FeedService()
        guard let parent = self.parent, let module = SortingAssembler.buildSortingModule(coordinator: self, service: service, delegate: parent.presenter) as? SortingFeedViewController else { return }
        
        self.sortingPresenter = module.presenter
        let navigation = UINavigationController(rootViewController: module)
        self.sortingNavigation = navigation
        
        self.navigationController.presentAsBottomSheet(navigation)
    }
    
    func hideSortingFeed() {
        self.navigationController.dismissBottomSheet()
        self.sortingPresenter = nil
        self.sortingNavigation = nil
    }
    
    func showColorParameters() {
        guard let navigation = sortingNavigation,
              let sortingPresenter = self.sortingPresenter else {
            return
        }
        
        let module = AvailableParametersAssembler.buildAvailableParametersModule(delegate: sortingPresenter, type: .color)
        
        navigation.pushViewController(module, animated: true)
    }
    
    func showSizeParameters() {
        guard let navigation = sortingNavigation,
              let sortingPresenter = self.sortingPresenter else {
            return
        }
        
        let module = AvailableParametersAssembler.buildAvailableParametersModule(delegate: sortingPresenter, type: .size)
        navigation.pushViewController(module, animated: true)
    }
    
    func showDetailedAd(with item: Item) {        
        let module = DetailedAdAssembler.buildDetailedAd(coordinator: self, item: item)
        
        self.navigationController.pushViewController(module, animated: true)
    }
    
    func showSearchScreen() {
        let module = SearchAssembler.buildSearchModule(coordinator: self)
        
        self.navigationController.pushViewController(module, animated: true)
    }
    
    public func showMessenger(brandId: String) {
        let messengerCoordinator = MessengerCoordinator(navigationController, role: .user)
        messengerCoordinator.finishFlow = { [weak self, weak messengerCoordinator] in
            guard let messengerCoordinator = messengerCoordinator else { return }
            
            self?.removeDependency(messengerCoordinator)
        }
        
        addDependency(messengerCoordinator)
        
        messengerCoordinator.showMessenger(conversationId: nil, brandId: brandId)
    }
    
}

// MARK: - SizePickerCoordinatorProtocol
extension FeedCoordinator: SizePickerCoordinatorProtocol {
    func showSizePicker(for item: Item) {
        let module = SizePickerAssembler.buildSizePickerModule(coordinator: self, with: item)
        
        let behavior: BottomSheetController.Behavior = .init(swipeMode: .top)
        self.navigationController.presentAsBottomSheet(module, behavior: behavior)
    }
    
    func hideSizePicker(with item: Cart) {
        self.navigationController.dismissBottomSheet {
            self.completionHandler?(item)
            self.navigationController.popViewController(animated: true)
        }
    }
}

