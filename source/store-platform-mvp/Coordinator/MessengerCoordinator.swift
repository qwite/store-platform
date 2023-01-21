import UIKit

// MARK: - MessengerRole
public enum MessengerRole: String {
    case user
    case brand
}

// MARK: - MessengerCoordinator
class MessengerCoordinator: BaseCoordinator, Coordinator {
    var navigationController: UINavigationController
    var role: MessengerRole?
    
    var finishFlow: (() -> ())?
    weak var imageDelegate: ImagePickerDelegate?
    
    func start() {
        showListMessages()
    }
    
    required init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    convenience init(_ navigationController: UINavigationController, role: MessengerRole) {
        self.init(navigationController)
        self.role = role
    }
}

// MARK: - MessagesCoordinatorProtocol Implementation
extension MessengerCoordinator: MessagesCoordinatorProtocol {
    func showListMessages() {
        guard let role = role else { return }
        
        let module = MessagesListAssembler.buildMessagesListModule(role: role, coordinator: self)
        
        self.navigationController.pushViewController(module, animated: true)
    }
    
    func showMessenger(conversationId: String?, brandId: String?) {
        guard let module = MessengerAssembler.buildMessengerModule(conversationId: conversationId, recipientBrandId: brandId, coordinator: self) as? MessengerViewController,
              let presenter = module.presenter as? ImagePickerDelegate else {
            return
        }
        
        self.imageDelegate = presenter
        self.navigationController.pushViewController(module, animated: true)
    }
        
    func showDetailedImage(data: Data) {
        let module = DetailedImageAssembler.buildDetailedImageModule(image: data)
        
        self.navigationController.pushViewController(module, animated: true)
    }
    
    func showImagePicker() {
        let imagePickerCoordinator = ImagePickerCoordinator(navigationController)
        
        imagePickerCoordinator.finishFlow = { [weak self, weak imagePickerCoordinator] image in
            guard let imagePickerCoordinator = imagePickerCoordinator else { return }
            self?.removeDependency(imagePickerCoordinator)
            
            guard let image = image else { return }
            self?.imageDelegate?.didImageAdded(image: image)
        }

        addDependency(imagePickerCoordinator)
        imagePickerCoordinator.start()
    }
}
