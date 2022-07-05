import Foundation

protocol RegisterPresenterProtocol {
    init(view: RegisterViewProtocol, coordinator: GuestCoordinator)

    func viewDidLoad()
    func createUser(email: String, password: String, firstName: String, lastName: String)
}

class RegisterPresenter: RegisterPresenterProtocol {
    weak var view: RegisterViewProtocol?
    weak var coordinator: GuestCoordinator?
    
    required init(view: RegisterViewProtocol, coordinator: GuestCoordinator) {
        self.view = view
        self.coordinator = coordinator
    }
    
    func viewDidLoad() {
        view?.configureRegisterButton()
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
        FirestoreService.sharedInstance.saveUserData(customUser: customUser) { result in
            switch result {
            case .success(_):
                RealTimeService.sharedInstance.insertUser(with: customUser) { error in
                    guard error == nil else {
                        fatalError("\(error!)")
                    }
                    self.view?.showSuccessRegister()
                    self.coordinator?.hideRegisterModal()
                }
            case .failure(let error):
                debugPrint("\(error)")
            }
        }
    }
}
