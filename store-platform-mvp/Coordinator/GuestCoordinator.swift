import UIKit

class GuestCoordinator: Coordinator {
    var navigationController: UINavigationController
    var factory: Factory
    
    var childCoordinator = [Coordinator]()
    
    func start() {
        let module = factory.buildGuestModule(coordinator: self)
        self.navigationController.pushViewController(module, animated: true)
    }
    
    func openLogin() {
        let module = factory.buildLoginModule()
        self.navigationController.present(module, animated: true)
    }
    
    func openRegister() {
        let module = factory.buildRegisterModule(coordinator: self)
        self.navigationController.present(module, animated: true)
    }
    
    func hideModal() {
        self.navigationController.dismiss(animated: true)
    }
    
    func remove() {
        self.navigationController.popViewController(animated: true)
    }
    
    required init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.factory = DependencyFactory()
    }
}
