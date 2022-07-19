import UIKit
import LBBottomSheet

class SellerCoordinator: BaseCoordinator, Coordinator {
    var navigationController: UINavigationController
    var factory: Factory?
    weak var delegate: ImagePickerPresenterDelegate?
    
    func start() {
        checkSellerStatus { status in
            switch status {
            case true:
                self.runSellerFlow()
            case false:
                self.runOnboardingFlow()
            }
        }
    }
    
    required init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.factory = DependencyFactory()
    }
    
    private func runOnboardingFlow() {
        let onboardingCoordinator = OnboardingCoordinator(navigationController)
        onboardingCoordinator.completionHandler = {
            self.removeDependency(onboardingCoordinator)
            self.runSellerFlow()
        }
        
        addDependency(onboardingCoordinator)
        onboardingCoordinator.start()
    }
    
    private func runSellerFlow() {
        let module = SellerAssembler.buildSellerModule(coordinator: self)
        
        self.navigationController.pushViewController(module, animated: true)
    }
    
    public func showMessenger(with id: String, brandId: String) {
        guard let module = factory?.buildMessengerModule(conversationId: id, brandId: brandId, coordinator: self) else {
            fatalError()
        }
        
        self.navigationController.pushViewController(module, animated: true)
    }
    
    public func showCreateAdScreen() {
        let createAdCoordinator = CreateAdCoordinator(navigationController)
        addDependency(createAdCoordinator)
        createAdCoordinator.start()

        createAdCoordinator.finishFlow = { [weak self] in
            self?.removeDependency(createAdCoordinator)
        }
    }
    
    public func showSellerOrders() {
        let module = SellerOrdersAssembler.buildSellerOrdersModule(coordinator: self)
        
        self.navigationController.pushViewController(module, animated: true)
    }
    
    public func changeOrderStatus(order: Order) {
        let module = ChangeOrderStatusAssembler.buildChangeOrderStatusModule(coordinator: self, order: order)
        
        let behavior: BottomSheetController.Behavior = .init(swipeMode: .top)
        self.navigationController.presentAsBottomSheet(module, behavior: behavior)
    }
    
    public func hideOrderStatus() {
        self.navigationController.dismissBottomSheet()
    }
}

extension SellerCoordinator: MessagesCoordinatorProtocol {
    func showImageDetail(image: Data) {
        guard let module = factory?.buildDetailedImageModule(image: image) else {
            fatalError()
        }
        
        self.navigationController.pushViewController(module, animated: true)
    }
    
    func showImagePicker() {
        // FIXME: remove from arc
        let imagePickerCoordinator = ImagePickerCoordinator(self.navigationController)
        imagePickerCoordinator.delegate = self.delegate
        imagePickerCoordinator.finish = { 
            self.removeDependency(imagePickerCoordinator)
            self.delegate = nil
        }
        addDependency(imagePickerCoordinator)
        imagePickerCoordinator.start()
    }
    
    func showMessenger(conversationId: String?, brandId: String?) {
        guard let module = factory?.buildMessengerModule(conversationId: conversationId, brandId: brandId, coordinator: self) as? MessengerViewController else {
            fatalError()
        }
        
        self.delegate = module.presenter
        self.navigationController.pushViewController(module, animated: true)
    }
    
    func showListMessages() {
        let module = MessagesListAssembler.buildMessagesListModule(role: .brand, coordinator: self)
        
        self.navigationController.pushViewController(module, animated: true)
    }
    
}

extension SellerCoordinator {
    func checkSellerStatus(completion: @escaping (Bool) -> ()) {
        let service = TOUserService()
        service.getSellerStatus { result in
            guard let _ = try? result.get() else {
                debugPrint("not seller")
                return completion(false)
            }
            
            completion(true)
        }
    }
}
