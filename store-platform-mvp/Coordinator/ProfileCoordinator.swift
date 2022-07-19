import UIKit

class ProfileCoordinator: BaseCoordinator, Coordinator {
    var navigationController: UINavigationController
    var factory: Factory?
    
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
        self.factory = DependencyFactory()
    }
    
    func showLogoutAlert() {
        let alert = UIAlertController(title: "Выход", message: "Вы действительно хотите выйти из аккаунта?", preferredStyle: .alert)
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
        guard let module = factory?.buildUserOrdersModule(coordinator: self) else { fatalError() }
        
        self.navigationController.pushViewController(module, animated: true)
    }
    
    func showDetailedProfile() {
        guard let module = factory?.buildDetailedProfileModule(coordinator: self) else { fatalError() }
        
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
        guard let module = factory?.buildDetailedOrderModule(coordinator: self, order: order) else { fatalError() }
        
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

extension ProfileCoordinator: MessagesCoordinatorProtocol {
    func showImageDetail(image: Data) {
        guard let module = factory?.buildDetailedImageModule(image: image) else {
            fatalError()
        }
        
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
        guard let module = factory?.buildMessengerModule(conversationId: conversationId, brandId: brandId, coordinator: self) as? MessengerViewController else {
            fatalError()
        }
        
        self.imagePickerDelegate = module.presenter
        
        self.navigationController.pushViewController(module, animated: true)
    }
}
