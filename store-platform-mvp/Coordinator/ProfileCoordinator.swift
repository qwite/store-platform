import UIKit

class ProfileCoordinator: BaseCoordinator, Coordinator {
    var navigationController: UINavigationController
    var factory: Factory?
    
    weak var delegate: ProfilePresenterDelegate?
    weak var tabDelegate: TabCoordinatorDelegate?
    weak var imagePickerDelegate: ImagePickerPresenterDelegate?
    
    var childCoordinator = [Coordinator]()
    
    func start() {
        guard let module = factory?.buildProfileModule(coordinator: self) else {
            return
        }
        
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
        guard let module = factory?.buildListMessagesModule(role: .user, coordinator: self) else {
            fatalError()
        }
        
        self.navigationController.pushViewController(module, animated: true)
    }
    
    func showMessenger(conversationId: String?, brandId: String?) {
        guard let module = factory?.buildMessengerModule(conversationId: conversationId, brandId: nil, coordinator: self) as? MessengerViewController else {
            fatalError()
        }
        self.imagePickerDelegate = module.presenter
        
        self.navigationController.pushViewController(module, animated: true)
    }
}
