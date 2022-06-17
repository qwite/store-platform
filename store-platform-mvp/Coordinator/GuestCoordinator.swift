import UIKit

class GuestCoordinator: Coordinator {
    var navigationController: UINavigationController
    var factory: Factory?
    weak var delegate: TabCoordinatorDelegate?
    var finish: (() -> ())?

    func start() {
        guard let module = factory?.buildGuestModule(coordinator: self) else {
            fatalError()
        }
        
        self.navigationController.pushViewController(module, animated: true)
    }
    
    func openLogin() {
        guard let module = factory?.buildLoginModule(coordinator: self) else {
            fatalError()
        }
        
        self.navigationController.present(module, animated: true)
    }
    
    func openRegister() {
        guard let module = factory?.buildRegisterModule(coordinator: self) as? RegisterViewController else {
            fatalError()
        }
        
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
