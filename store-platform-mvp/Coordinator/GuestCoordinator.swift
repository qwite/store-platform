import UIKit

class GuestCoordinator: Coordinator {
    var navigationController: UINavigationController
    var factory: Factory
    weak var delegate: TabCoordinatorDelegate?
    
    var childCoordinator = [Coordinator]()
    
    func start() {
        let module = factory.buildGuestModule(coordinator: self)
        self.navigationController.pushViewController(module, animated: true)
    }
    
    var finish: (() -> ())?
    
    func openLogin() {
        let module = factory.buildLoginModule(coordinator: self)
        self.navigationController.present(module, animated: true)
    }
    
    func openRegister() {
        let module = factory.buildRegisterModule(coordinator: self)
        self.navigationController.present(module, animated: true)
    }
    
    func hideLoginModal() {
        self.navigationController.dismiss(animated: true) {
            self.delegate?.updatePages()
        }
        
        self.finish?()
        self.navigationController.popViewController(animated: false)
    }
    
    func hideRegisterModal() {
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
