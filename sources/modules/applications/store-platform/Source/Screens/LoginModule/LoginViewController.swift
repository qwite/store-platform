// ----------------------------------------------------------------------------
//
//  LoginViewController.swift
//
//  @author     Artem Lashmanov <https://github.com/qwite>
//  @copyright  Copyright (c) 2023
//
// ----------------------------------------------------------------------------

import SPAlert
import UIKit

// ----------------------------------------------------------------------------

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

        self.presenter.viewDidLoad()
    }

    func configureViews() {
        _loginView.configure()

        _loginView.loginButton.addTarget(self, action: #selector(didTappedLoginButton), for: .touchUpInside)
    }

    @objc func didTappedLoginButton() {
        guard let email = _loginView.emailTextField.text, !email.isEmpty,
              let password = _loginView.passwordTextField.text, !password.isEmpty
        else {
            showErrorMessage(message: "Поля не заполнены")
            return
        }

        self.presenter.login(email: email, password: password)
    }

// MARK: - Variables

    private var _loginView = LoginView()
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
