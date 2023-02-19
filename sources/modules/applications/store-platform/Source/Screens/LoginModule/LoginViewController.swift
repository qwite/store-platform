import UIKit
import SPAlert

@MainActor
protocol LoginViewProtocol: AnyObject {

// MARK: - Methods

    func showErrorMessage(message: String)

    func showSuccessMessage(message: String)
}

class LoginViewController: UIViewController {

// MARK: - Properties

    var presenter: LoginPresenterProtocol!

// MARK: - Methods

    override func loadView() {
        view = _loginView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureViews()

        presenter.viewDidLoad()
    }

    func configureViews() {
        _loginView.configure()

        _loginView.loginButton.addTarget(self, action: #selector(didTappedLoginButton), for: .touchUpInside)
    }

    @objc func didTappedLoginButton() {
        guard let email = _loginView.emailTextField.text, !email.isEmpty,
              let password = _loginView.passwordTextField.text, !password.isEmpty else {
//                  presenter.handleError(error: .emptyFieldsError); return
                return
              }

        presenter.login(email: email, password: password)
    }

// MARK: - Variables

    var _loginView = LoginView()
}


// ----------------------------------------------------------------------------
// MARK: - @protocol LoginViewProtocol
// ----------------------------------------------------------------------------

extension LoginViewController: LoginViewProtocol {

// MARK: - Methods

    func showSuccessMessage(message: String) {
        SPAlert.present(message: message, haptic: .success)
    }
    
    func showErrorMessage(message: String) {
        SPAlert.present(message: message, haptic: .error)
    }
}
