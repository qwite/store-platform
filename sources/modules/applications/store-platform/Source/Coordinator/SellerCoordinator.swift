import UIKit
import LBBottomSheet

class SellerCoordinator: BaseCoordinator, Coordinator {
    var navigationController: UINavigationController
    weak var imageDelegate: ImagePickerDelegate?
    
    func start() {
        checkSellerStatus { [weak self] status in
            switch status {
            case true:
                self?.runSellerFlow()
            case false:
                self?.runOnboardingFlow()
            }
        }
    }
    
    required init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    private func runOnboardingFlow() {
        let onboardingCoordinator = OnboardingCoordinator(navigationController)
        onboardingCoordinator.finishFlow = { [weak self, weak onboardingCoordinator] in
            guard let onboardingCoordinator = onboardingCoordinator else { return }
            
            self?.removeDependency(onboardingCoordinator)
            self?.runSellerFlow()
        }
        
        addDependency(onboardingCoordinator)
        onboardingCoordinator.start()
    }
    
    private func runSellerFlow() {
        let module = SellerAssembler.buildSellerModule(coordinator: self)
        
        self.navigationController.pushViewController(module, animated: true)
    }
    
    // FIXME: Allocation bug
    public func showCreateAdScreen() {
        let createAdCoordinator = CreateAdCoordinator(navigationController)

        createAdCoordinator.finishFlow = { [weak self, weak createAdCoordinator] in
            guard let createAdCoordinator = createAdCoordinator else { return }
            
            self?.removeDependency(createAdCoordinator)
        }
        
        addDependency(createAdCoordinator)
        createAdCoordinator.start()
    }
    
    public func showSellerOrders() {
        let module = SellerOrdersAssembler.buildSellerOrdersModule(coordinator: self)
        
        self.navigationController.pushViewController(module, animated: true)
    }
    
    public func changeOrderStatus(order: Order) {
        // TODO("Create change order status screen")
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
