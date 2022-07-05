import Foundation

// MARK: - LoginPresenter Protocol
protocol LoginPresenterProtocol {
    init(view: LoginViewProtocol, coordinator: GuestCoordinator)
    func viewDidLoad()
    
    func login(email: String, password: String)
    func getUserInfo(id: String)
    func saveUser(_ user: UserData)
    func handleError(error: AuthServiceError)
}

// MARK: - LoginPresenter Implementation
class LoginPresenter: LoginPresenterProtocol {
    weak var view: LoginViewProtocol?
    weak var coordinator: GuestCoordinator?
    
    required init(view: LoginViewProtocol, coordinator: GuestCoordinator) {
        self.view = view
        self.coordinator = coordinator
    }
    
    func viewDidLoad() {
        view?.configure()
    }
    
    func login(email: String, password: String) {
        AuthService.sharedInstance.login(email: email, password: password) { [weak self] result in
            switch result {
            case .success(let user):
                self?.getUserInfo(id: user.uid)
            case .failure(let error):
                self?.handleError(error: error)
            }
        }
    }
    
    func getUserInfo(id: String) {
        FirestoreService.sharedInstance.fetchUserData(by: id) { [weak self] result in
            switch result {
            case .success(let user):
                self?.saveUser(user)
                self?.view?.showSuccessMessage(message: Constants.Messages.successUserLogin)
                self?.coordinator?.finishFlow()
            case .failure(let error):
                debugPrint(error)
            }
        }
    }
    
    func saveUser(_ user: UserData) {
        guard let firstName = user.firstName,
              let lastName = user.lastName,
              let userId = user.id else {
            fatalError("\(AuthServiceError.emptyFieldsError)")
        }
        
        let userFullName = ["firstName": firstName, "lastName": lastName]
        
        SettingsService.sharedInstance.saveUserData(userId: userId, userFullName: userFullName)
        
        debugPrint("\(user) saved")
    }
    
    func handleError(error: AuthServiceError) {
        var message: String = ""
        
        switch error {
        case .signInError:
            message = Constants.Errors.loginError
        case .createAccountError:
            message = Constants.Errors.registerError
        case .emptyFieldsError:
            message = Constants.Errors.emptyFieldsError
        default:
            message = Constants.Errors.unknownError
        }
        
        view?.showErrorMessage(message: message)
    }
}
