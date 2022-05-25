import Foundation

protocol LoginPresenterProtocol: AnyObject {
    init(view: LoginViewProtocol)
    func viewDidLoad()
    func login(email: String, password: String)
    func getUserInfo(id: String)
}

class LoginPresenter: LoginPresenterProtocol {
    var view: LoginViewProtocol
    required init(view: LoginViewProtocol) {
        self.view = view
    }
    
    func viewDidLoad() {
        view.configureLoginButton()
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
        FirestoreService.sharedInstance.getUserInfo(by: id) { result in
            switch result {
            case .success(let data):
                debugPrint(data)
            case .failure(let error):
                debugPrint(error)
            }
        }
    }
}
