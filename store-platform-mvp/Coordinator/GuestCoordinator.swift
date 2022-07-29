import UIKit

class GuestCoordinator: Coordinator {
    var navigationController: UINavigationController
    weak var delegate: TabCoordinatorDelegate?
    var finish: (() -> ())?

    required init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let module = GuestAssembler.buildGuestModule(coordinator: self)
        
        self.navigationController.pushViewController(module, animated: true)
    }
    
    func openLogin() {
        let module = LoginAssembler.buildLoginModule(coordinator: self)
        
        self.navigationController.present(module, animated: true)
    }
    
    func openRegister() {        
        let module = RegisterAssembler.buildRegisterModule(coordinator: self)
        
        self.navigationController.present(module, animated: true)
    }
    
    func finishFlow() {
        self.navigationController.dismiss(animated: true) { [weak self] in
            self?.delegate?.updatePages()
            self?.finish?()
        }
    }
    
    func hideRegisterModal() {
        self.navigationController.dismiss(animated: true)
    }
    
    func remove() {
        self.navigationController.popViewController(animated: true)
    }
}
