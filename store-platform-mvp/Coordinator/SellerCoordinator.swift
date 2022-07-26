import UIKit
import LBBottomSheet

class SellerCoordinator: BaseCoordinator, Coordinator {
    var navigationController: UINavigationController
    
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
        let module = MessengerAssembler.buildMessengerModule(conversationId: id, brandId: brandId, coordinator: self)
        
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

// MARK: - MessagesCoordinatorProtocol
extension SellerCoordinator: MessagesCoordinatorProtocol {
    func showImageDetail(image: Data) {
        let module = DetailedImageAssembler.buildDetailedImageModule(image: image)
        
        self.navigationController.pushViewController(module, animated: true)
    }
    
    func showImagePicker() {
        let imagePickerCoordinator = ImagePickerCoordinator(self.navigationController)
//        imagePickerCoordinator.finishFlow = { image in
//            self.removeDependency(imagePickerCoordinator)
//        }
        
        addDependency(imagePickerCoordinator)
        imagePickerCoordinator.start()
    }
    
    func showMessenger(conversationId: String?, brandId: String?) {
        guard let module = MessengerAssembler.buildMessengerModule(conversationId: conversationId, brandId: brandId, coordinator: self) as? MessengerViewController else {
            return
        }
        
        self.navigationController.pushViewController(module, animated: true)
    }
    
    func showListMessages() {
        let module = MessagesListAssembler.buildMessagesListModule(role: .brand, coordinator: self)
        
        self.navigationController.pushViewController(module, animated: true)
    }
    
}

extension SellerCoordinator {
    func checkSellerStatus(completion: @escaping (Bool) -> ()) {
        guard let userId = SettingsService.sharedInstance.userId else {
            return
        }
        
        FirestoreService.sharedInstance.getSellerStatus(userId: userId) { result in
            guard let _ = try? result.get() else {
                completion(false); return
            }
            
            completion(true)
        }
    }
}
