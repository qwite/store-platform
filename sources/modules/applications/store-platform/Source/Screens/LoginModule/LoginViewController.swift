import UIKit
import SPAlert

@MainActor
protocol LoginViewProtocol: AnyObject {
    func configure()
    func configureLoginButton()
    func didTappedLoginButton()
    
    func showSuccessMessage(message: String)
    func showErrorMessage(message: String)
}

// MARK: - LoginViewController
class LoginViewController: UIViewController {
    var loginView = LoginView()
    var presenter: LoginPresenterProtocol!
   
    //MARK: Lifecycle
    override func loadView() {
        view = loginView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewDidLoad()
    }
    
    deinit {
        debugPrint("[Log] Login VC deinit")
    }
}

// MARK: - LoginView Implementation
extension LoginViewController: LoginViewProtocol {
    func configure() {
        loginView.configure()
        configureLoginButton()
    }
    
    @objc func didTappedLoginButton() {
        guard let email = loginView.emailTextField.text, !email.isEmpty,
              let password = loginView.passwordTextField.text, !password.isEmpty else {
//                  presenter.handleError(error: .emptyFieldsError); return
                return
              }
        
        presenter.login(email: email, password: password)
    }
    
    func configureLoginButton() {
        loginView.loginButton.addTarget(self, action: #selector(didTappedLoginButton), for: .touchUpInside)
    }
    
    func showSuccessMessage(message: String) {
        SPAlert.present(message: message, haptic: .success)
    }
    
    func showErrorMessage(message: String) {
        SPAlert.present(message: message, haptic: .error)
    }
}
