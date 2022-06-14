import Foundation

protocol LoginPresenterProtocol: AnyObject {
    init(view: LoginViewProtocol, coordinator: GuestCoordinator)
    func viewDidLoad()
    func login(email: String, password: String)
    func getUserInfo(id: String)
    func saveUser(_ user: CustomUser)
}

class LoginPresenter: LoginPresenterProtocol {
    weak var view: LoginViewProtocol?
    weak var coordinator: GuestCoordinator?
    
    required init(view: LoginViewProtocol, coordinator: GuestCoordinator) {
        self.view = view
        self.coordinator = coordinator
    }
    
    func viewDidLoad() {
        view?.configureLoginButton()
    }
    
    func login(email: String, password: String) {
        AuthService.sharedInstance.login(email: email, password: password) { result in
            switch result {
            case .success(let user):
                self.getUserInfo(id: user.uid)
            case .failure(let error):
                debugPrint(error)
            }
        }
    }
    
    func getUserInfo(id: String) {
        FirestoreService.sharedInstance.getUserInfo(by: id) { [weak self] result in
            switch result {
            case .success(let user):
                self?.saveUser(user)
                self?.view?.showSuccessLogin()
                self?.coordinator?.hideLoginModal()
            case .failure(let error):
                debugPrint(error)
            }
        }
    }
    
    func saveUser(_ user: CustomUser) {
        guard let firstName = user.firstName,
              let lastName = user.lastName else {
            fatalError("user cannot be saved")
        }
        
        SettingsService.sharedInstance.isAuthorized = true
        SettingsService.sharedInstance.userId = user.id
        SettingsService.sharedInstance.userFullName = ["firstName": firstName, "lastName": lastName]
        
        debugPrint("\(user) saved")
    }
}
