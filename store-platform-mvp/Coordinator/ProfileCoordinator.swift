import UIKit

// MARK: - ProfileCoordinator
class ProfileCoordinator: BaseCoordinator, Coordinator {
    var navigationController: UINavigationController
    
    weak var delegate: ProfilePresenterDelegate?
    weak var tabDelegate: TabCoordinatorDelegate?
    weak var imageDelegate: ImagePickerDelegate?
    
    var childCoordinator = [Coordinator]()
    
    func start() {
        let module = ProfileAssembler.buildProfileModule(coordinator: self)
        
        self.navigationController.pushViewController(module, animated: true)
    }
    
    required init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func showLogoutAlert() {
        let alert = UIAlertController(title: "Выход", message: Constants.Messages.logoutMessage, preferredStyle: .alert)
        let logoutAction = UIAlertAction(title: "Выход", style: .destructive) { alert in
            self.delegate?.didTappedLogoutButton()
        }
        
        alert.addAction(logoutAction)
        
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel) { alert in
            print("Отмена")
        }
        
        alert.addAction(cancelAction)
        
        self.navigationController.present(alert, animated: true)
    }
    
    func showUserOrders() {
        let module = UserOrdersAssembler.buildUserOrdersModule(coordinator: self)
        
        self.navigationController.pushViewController(module, animated: true)
    }
    
    func showDetailedProfile() {
        let module = DetailedProfileAssembler.buildDetailedProfileModule(coordinator: self)
        
        self.navigationController.pushViewController(module, animated: true)
    }
    
    func showSettings() {
        let module = SettingsAssembler.buildSettingsModule(coordinator: self)
        
        self.navigationController.pushViewController(module, animated: true)
    }
    
    func showSubscriptions() {
        let module = SubscriptionsAssembler.buildSubscriptionsModule(coordinator: self)
        
        self.navigationController.pushViewController(module, animated: true)
    }
    
    func showDetailedOrder(order: Order) {
        let module = DetailedOrderAssembler.buildDetailedOrderModule(coordinator: self, order: order)
        
        self.navigationController.presentAsBottomSheet(module)
    }
    
    func hideDetailedOrder(brandId: String?) {
        
        self.navigationController.dismissBottomSheet {
//            self.showMessenger(conversationId: nil, brandId: brandId)
        }
    }
    
    public func backToRoot() {
        self.navigationController.popToRootViewController(animated: true)
    }
    
    public func showListMessages() {
        let messengerCoordinator = MessengerCoordinator(navigationController, role: .user)
        messengerCoordinator.finishFlow = { [weak self, weak messengerCoordinator] in
            guard let messengerCoordinator = messengerCoordinator else { return }
            
            self?.removeDependency(messengerCoordinator)
        }
        
        addDependency(messengerCoordinator)
        messengerCoordinator.showListMessages()
    }
    
    func updateTabPages() {
        tabDelegate?.updatePages()
    }
}

