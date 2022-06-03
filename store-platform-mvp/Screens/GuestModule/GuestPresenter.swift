import Foundation

protocol GuestPresenterProtocol {
    init(view: GuestViewProtocol, coordinator: GuestCoordinator)
    func openLogin()
    func openRegister()
}

class GuestPresenter: GuestPresenterProtocol {
    weak var view: GuestViewProtocol?
    weak var coordinator: GuestCoordinator?
    
    required init(view: GuestViewProtocol, coordinator: GuestCoordinator) {
        self.view = view
        self.coordinator = coordinator
    }
    
    func viewDidLoad() {
        view?.configureViews()
        view?.configureButtons()
    }
    
    func openLogin() {
        coordinator?.openLogin()
    }
    
    func openRegister() {
        coordinator?.openRegister()
    }
}
