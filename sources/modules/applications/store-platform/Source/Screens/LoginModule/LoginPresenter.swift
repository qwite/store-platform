import CoreFirebaseService
import Foundation

// MARK: - LoginPresenter Protocol
protocol LoginPresenterProtocol {
    init(view: LoginViewProtocol, coordinator: GuestCoordinator, service: UserServiceProtocol)
    func viewDidLoad()
    
    func login(email: String, password: String)
    func getUserInfo(id: String)
    func saveUser(_ user: UserData)
//    func handleError(error: AuthServiceError)
}

// MARK: - LoginPresenter Implementation
class LoginPresenter: LoginPresenterProtocol {

// MARK: - Properties

    weak var view: LoginViewProtocol?
    weak var coordinator: GuestCoordinator?
    var service: UserServiceProtocol?
    var authorizationService: IAuthorizationService = AuthorizationService()

    required init(view: LoginViewProtocol, coordinator: GuestCoordinator, service: UserServiceProtocol) {
        self.view = view
        self.coordinator = coordinator
        self.service = service
    }
    
    func viewDidLoad() {
        Task {
            await view?.configure()
        }
    }

    func login(email: String, password: String) {
        Task {
            do {
                let user = try await authorizationService.login(email: email, password: password)
                getUserInfo(id: user.uid)
            } catch {
                await view?.showErrorMessage(message: "Произошла ошибка при авторизации")
            }
        }
    }

//    func login(email: String, password: String) {
//        AuthService.sharedInstance.login(email: email, password: password) { [weak self] result in
//            switch result {
//            case .success(let user):
//                self?.getUserInfo(id: user.uid)
//            case .failure(let error):
//                self?.handleError(error: error)
//            }
//        }
//    }
    
    func getUserInfo(id: String) {
        service?.fetchUserData(by: id, completion: { [weak self] result in
            switch result {
            case .success(let user):
                self?.saveUser(user)

//                Task {
//                    await self?.view?.showSuccessMessage(message: Constants.Messages.successUserLogin)
//                }

                self?.coordinator?.finishFlow()
            case .failure(let error):
                print(error)
            }
        })
    }
    
    
    func saveUser(_ user: UserData) {        
        let firstName = user.firstName
        let lastName = user.lastName
        let userId = user.id
        
        let userFullName = ["firstName": firstName, "lastName": lastName]
        
        SettingsService.sharedInstance.saveUserData(userId: userId, userFullName: userFullName)
    }
    
//    func handleError(error: AuthServiceError) {
//        var message: String = ""
//
//        switch error {
//        case .signInError:
//            message = Constants.Errors.loginError
//        case .createAccountError:
//            message = Constants.Errors.registerError
//        case .emptyFieldsError:
//            message = Constants.Errors.emptyFieldsError
//        default:
//            message = Constants.Errors.unknownError
//        }
//
//        view?.showErrorMessage(message: message)
//    }
}
