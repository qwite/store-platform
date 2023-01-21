import UIKit

// MARK: - LoginView
class LoginView: UIView {
    // MARK: - Properties
    let emailTextField = UITextField(placeholder: "Электронная почта",
                                      withUnderline: true,
                                      keyboardType: .emailAddress)
    
    let passwordTextField = UITextField(placeholder: "Пароль",
                                         withUnderline: true,
                                         keyboardType: .default,
                                         isSecureTextEntry: true)
    
    let loginButton = UIButton(text: "Войти", preset: .customLarge)
}

// MARK: - Public methods
extension LoginView {
    public func configure() {
        setupViews()
    }
}

// MARK: - Private methods
extension LoginView {
    private func setupViews() {
        backgroundColor = .white
        
        emailTextField.autocapitalizationType = .none
        emailTextField.autocorrectionType = .no
        passwordTextField.autocorrectionType = .no
        
        let stack = UIStackView(arrangedSubviews: [emailTextField,
                                                   passwordTextField,
                                                   loginButton],
                                spacing: 20, axis: .vertical, alignment: .fill)
        
        addSubview(stack)
        stack.distribution = .fillEqually
        
        stack.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide.snp.top).offset(20)
            make.left.equalTo(safeAreaLayoutGuide.snp.left).offset(20)
            make.right.equalTo(safeAreaLayoutGuide.snp.right).offset(-20)
        }
    }
}
