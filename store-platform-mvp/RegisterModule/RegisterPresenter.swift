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
                let customUser = CustomUser(id: user.uid, firstName: firstName, lastName: lastName, email: email)
                self.saveUserInfo(customUser: customUser)
            case .failure(let error):
                debugPrint(error)
            }
        }
    }
    
    func saveUserInfo(customUser: CustomUser) {
        FirestoreService.sharedInstance.saveUserInfo(customUser: customUser) { result in
            switch result {
            case .success(_):
                self.view?.showSuccessRegister()
                self.coordinator?.hideModal()
            case .failure(let error):
                debugPrint("\(error)")
            }
        }
    }
}
