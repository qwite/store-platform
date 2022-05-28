import UIKit
import SPAlert

// MARK: - LoginView Protocol
protocol LoginViewProtocol: AnyObject {
    func configureLoginButton()
    func didTappedLoginButton()
    func showSuccessLogin()
}

class LoginViewController: UIViewController {
    var loginView = LoginView()
    var presenter: LoginPresenter!
   
    //MARK: - Lifecycle
    
    override func loadView() {
        view = loginView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "test"
        loginView.setupViews()
        presenter.viewDidLoad()
    }
    
    deinit {
        debugPrint("login vc deinit")
    }
}

// MARK: - LoginView Protocol implementation
extension LoginViewController: LoginViewProtocol {
    @objc func didTappedLoginButton() {
        let email = loginView.emailField.text
        let password = loginView.passwordField.text
        
        guard let email = email, let password = password else {
            fatalError("Unwrap error")
        }
        
        presenter.login(email: email, password: password)
    }
    
    func configureLoginButton() {
        loginView.loginButton.addTarget(self, action: #selector(didTappedLoginButton), for: .touchUpInside)
    }
    
    func showSuccessLogin() {
        SPAlert.present(message: "Успешная авторизация!", haptic: .success)
    }
}


// MARK: - SwiftUI

import SwiftUI
struct LoginViewPreview: PreviewProvider {
    static var previews: some View {
        ContainerView().edgesIgnoringSafeArea(.all)
    }
    
    struct ContainerView: UIViewControllerRepresentable {
        
        func makeUIViewController(context: UIViewControllerRepresentableContext<LoginViewPreview.ContainerView>)
        -> LoginViewController {
            return LoginViewController()
        }
        
        func updateUIViewController(_ uiViewController: LoginViewPreview.ContainerView.UIViewControllerType,
                                    context: UIViewControllerRepresentableContext<LoginViewPreview.ContainerView>) {}
    }
}
