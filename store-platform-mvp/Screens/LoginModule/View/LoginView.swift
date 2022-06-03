import UIKit

class LoginView: UIView {
    lazy var emailField = UITextField(placeholder: "Электронная почта",
                                      withUnderline: true,
                                      keyboardType: .emailAddress)
    
    lazy var passwordField = UITextField(placeholder: "Пароль",
                                         withUnderline: true,
                                         keyboardType: .default,
                                         isSecureTextEntry: true)
    
    lazy var loginButton = UIButton(text: "Войти", preset: .customLarge)
    
    lazy var forgotPasswordButton = UIButton(text: "Забыли пароль?", preset: .none)
    
    lazy var stack = UIStackView(arrangedSubviews: [emailField,
                                                    passwordField,
                                                    loginButton,
                                                    forgotPasswordButton],
                                 spacing: 20, axis: .vertical, alignment: .fill)
    
    func setupViews() {
        backgroundColor = .white
        
        emailField.autocapitalizationType = .none
        emailField.autocorrectionType = .no
        passwordField.autocorrectionType = .no
        
        addSubview(stack)
        stack.distribution = .fillEqually
        stack.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide.snp.top).offset(20)
            make.left.equalTo(safeAreaLayoutGuide.snp.left).offset(20)
            make.right.equalTo(safeAreaLayoutGuide.snp.right).offset(-20)
        }
    }
}
