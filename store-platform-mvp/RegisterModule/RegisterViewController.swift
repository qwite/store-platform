import UIKit
import SPAlert

protocol RegisterViewProtocol {
    func configureRegisterButton()
    func didTappedRegisterButton()
    func showSuccessRegister()
}

class RegisterViewController: UIViewController {
    var registerView = RegisterView()
    var presenter: RegisterPresenter!
    //MARK: - Lifecycle
    
    override func loadView() {
        view = registerView
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        registerView.setupViews()
        presenter.viewDidLoad()
    }
}

extension RegisterViewController: RegisterViewProtocol {
    func showSuccessRegister() {
        SPAlert.present(message: "Успешная регистрация!", haptic: .success)
    }
    
    func configureRegisterButton() {
        registerView.registerButton.addTarget(self, action: #selector(didTappedRegisterButton), for: .touchUpInside)
    }
    
    @objc func didTappedRegisterButton() {
        let email = registerView.emailField.text
        let password = registerView.passwordField.text
        let firstName = registerView.firstNameField.text
        let lastName = registerView.lastNameField.text
        
        guard let email = email,
              let password = password,
              let firstName = firstName,
              let lastName = lastName else {
            return debugPrint("Ошибка при заполнении данных")
        }
        
        presenter.createUser(email: email, password: password, firstName: firstName, lastName: lastName)
    }
}
