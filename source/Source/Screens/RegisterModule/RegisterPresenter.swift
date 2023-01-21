import Foundation

// MARK: - RegisterPresenterProtocol
protocol RegisterPresenterProtocol {
    init(view: RegisterViewProtocol, coordinator: GuestCoordinator, service: UserServiceProtocol)

    func viewDidLoad()
    func createUser(email: String, password: String, firstName: String, lastName: String)
}

// MARK: - RegisterPresenterProtocol Implementation
class RegisterPresenter: RegisterPresenterProtocol {
    weak var view: RegisterViewProtocol?
    weak var coordinator: GuestCoordinator?
    var service: UserServiceProtocol?
    
    required init(view: RegisterViewProtocol, coordinator: GuestCoordinator, service: UserServiceProtocol) {
        self.view = view
        self.coordinator = coordinator
        self.service = service
    }
    
    func viewDidLoad() {
        view?.configure()
    }
    
    func createUser(email: String, password: String, firstName: String, lastName: String) {
        AuthService.sharedInstance.register(email: email, password: password) { result in
            switch result {
            case .success(let user):
                let customUser = UserData(id: user.uid, firstName: firstName, lastName: lastName, email: email)
                self.saveUserInfo(customUser: customUser)
            case .failure(let error):
                debugPrint(error)
            }
        }
    }
    
    func saveUserInfo(customUser: UserData) {
        service?.saveUserData(userData: customUser, completion: { [weak self] error in
            guard error == nil else { print(error!); return }
            
            self?.view?.showSuccessRegister()
            self?.coordinator?.hideRegisterModal()
        })
    }
}
