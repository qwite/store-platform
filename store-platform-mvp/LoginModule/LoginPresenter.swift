import Foundation

protocol LoginPresenterProtocol: AnyObject {
    init(view: LoginViewProtocol)
    func viewDidLoad()
    func login(email: String, password: String)
    func getUserInfo(id: String)
    func saveUser(_ user: CustomUser)
}

class LoginPresenter: LoginPresenterProtocol {
    weak var view: LoginViewProtocol?
    required init(view: LoginViewProtocol) {
        self.view = view
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
            case .failure(let error):
                debugPrint(error)
            }
        }
    }
    
    func saveUser(_ user: CustomUser) {
        debugPrint("\(user) saved")
        SettingsService.sharedInstance.isAuthorized = true
        SettingsService.sharedInstance.userId = user.id
    }
}
