import UIKit
import LBBottomSheet

class SellerCoordinator: BaseCoordinator, Coordinator {
    var navigationController: UINavigationController
    weak var imageDelegate: ImagePickerDelegate?
    
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
    
//    public func showMessenger(with id: String, brandId: String) {
//        let module = MessengerAssembler.buildMessengerModule(conversationId: id, brandId: brandId, coordinator: self)
//
//        self.navigationController.pushViewController(module, animated: true)
//    }
    
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
    
    public func showListMessages() {
        let messengerCoordinator = MessengerCoordinator(self.navigationController, role: .brand)
        addDependency(messengerCoordinator)
        messengerCoordinator.finishFlow = { [weak self, weak messengerCoordinator] in
            guard let messengerCoordinator = messengerCoordinator else { return }
            
            self?.removeDependency(messengerCoordinator)
        }
        
        messengerCoordinator.showListMessages()
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
