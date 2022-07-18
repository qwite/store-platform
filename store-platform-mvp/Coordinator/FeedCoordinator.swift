import UIKit
import LBBottomSheet

class FeedCoordinator: BaseCoordinator, Coordinator {
    var navigationController: UINavigationController
    var factory: Factory?
    var completionHandler: ((Cart) -> ())?
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
        let module = DetailedAdAssembler.buildDetailedAd(coordinator: self, item: item)
        
        self.navigationController.pushViewController(module, animated: true)
    }
    
    func showSearchScreen() {
        let module = SearchAssembler.buildSearchModule(coordinator: self)
        
        self.navigationController.pushViewController(module, animated: true)
    }
    
}

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

