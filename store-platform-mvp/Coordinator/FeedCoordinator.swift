import UIKit
import LBBottomSheet

class FeedCoordinator: BaseCoordinator, Coordinator {
    var navigationController: UINavigationController
    var factory: Factory?
    var completionHandler: ((CartItem) -> ())?
    var parent: FeedViewController?
    weak var imagePickerDelegate: ImagePickerPresenterDelegate?

    var sortingPresenter: SortingFeedPresenterProtocol?
    var sortingNavigation: UINavigationController?
    
    required init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
        factory = DependencyFactory()
    }
    
    deinit {
    }
    
    var finish: (() -> ())?
    
    func start() {
        self.showFeed()
    }
    
    func showFeed(with items: [Item]? = nil) {
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
        self.navigationController.dismissBottomSheet()
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
        
        let behavior: BottomSheetController.Behavior = .init(swipeMode: .top)
        self.navigationController.presentAsBottomSheet(module, behavior: behavior)
    }
    
    func hideSizePicker(with item: CartItem) {
        self.navigationController.dismissBottomSheet {
            self.completionHandler?(item)
            self.navigationController.popViewController(animated: true)
        }
    }
}

extension FeedCoordinator: MessagesCoordinatorProtocol {
    func showListMessages() {
        
    }
    
    func showMessenger(conversationId: String?, brandId: String?) {
        guard let module = factory?.buildMessengerModule(conversationId: nil, brandId: brandId, coordinator: self) as? MessengerViewController  else {
            fatalError()
        }
        
        self.imagePickerDelegate = module.presenter

        
        self.navigationController.pushViewController(module, animated: true)
    }
    
    func showImagePicker() {
        // FIXME: remove from arc
        let imagePickerCoordinator = ImagePickerCoordinator(self.navigationController)
        imagePickerCoordinator.delegate = self.imagePickerDelegate
        
        imagePickerCoordinator.finish = {
            self.removeDependency(imagePickerCoordinator)
            self.imagePickerDelegate = nil
        }
        addDependency(imagePickerCoordinator)
        imagePickerCoordinator.start()
    }
    
    func showImageDetail(image: Data) {
        
    }
}

