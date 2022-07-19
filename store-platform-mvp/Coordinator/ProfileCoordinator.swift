import UIKit

// MARK: - ProfileCoordinator
class ProfileCoordinator: BaseCoordinator, Coordinator {
    var navigationController: UINavigationController
    
    weak var delegate: ProfilePresenterDelegate?
    weak var tabDelegate: TabCoordinatorDelegate?
    weak var imagePickerDelegate: ImagePickerPresenterDelegate?
    
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
            self.showMessenger(conversationId: nil, brandId: brandId)
        }
    }
    
    func updateTabPages() {
        tabDelegate?.updatePages()
    }
}

// MARK: - MessagesCoordinatorProtocol
extension ProfileCoordinator: MessagesCoordinatorProtocol {
    func showImageDetail(image: Data) {
        let module = DetailedImageAssembler.buildDetailedImageModule(image: image)
        
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
    
    func showListMessages() {
        let module = MessagesListAssembler.buildMessagesListModule(role: .user, coordinator: self)

        self.navigationController.pushViewController(module, animated: true)
    }
    
    func showMessenger(conversationId: String?, brandId: String?) {
        guard let module = MessengerAssembler.buildMessengerModule(conversationId: conversationId, brandId: brandId, coordinator: self) as? MessengerViewController else {
            return
        }
        
        self.imagePickerDelegate = module.presenter
        
        self.navigationController.pushViewController(module, animated: true)
    }
}
