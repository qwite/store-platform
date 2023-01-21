import UIKit

// MARK: - RegisterView
class RegisterView: UIView {
    // MARK: Properties
    lazy var firstNameField = UITextField(placeholder: "Имя", withUnderline: true, keyboardType: .default)
    lazy var lastNameField = UITextField(placeholder: "Фамилия", withUnderline: true, keyboardType: .default)
    lazy var emailField = UITextField(placeholder: "Электронная почта", withUnderline: true, keyboardType: .emailAddress)
    lazy var passwordField = UITextField(placeholder: "Пароль", withUnderline: true, keyboardType: .default,
                                         isSecureTextEntry: true)
    lazy var registerButton = UIButton(text: "Зарегистрироваться", preset: .customLarge)
    
    lazy var conditionsLabel = UILabel(text: "Регистрируясь, вы принимаете следующие условия Политики конфиденциальности и условия Пользования",
                                       font: UIFont.systemFont(ofSize: 14, weight: .regular),
                                       textColor: .black)
}

// MARK: - Public methods
extension RegisterView {
    func configure() {
        setupViews()
    }
}
// MARK: - Private methods
extension RegisterView {
    private func setupViews() {
        backgroundColor = .white
        emailField.autocapitalizationType = .none
        emailField.autocorrectionType = .no
        passwordField.autocorrectionType = .no
        conditionsLabel.numberOfLines = 0
        
        
        let stack = UIStackView(arrangedSubviews: [firstNameField,
                                                   lastNameField,
                                                   emailField,
                                                   passwordField,
                                                   conditionsLabel
                                                  ],
                                spacing: 20, axis: .vertical, alignment: .fill)
        
        stack.distribution = .fillEqually
        addSubview(stack)
        
        stack.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide.snp.top).offset(20)
            make.left.equalTo(safeAreaLayoutGuide.snp.left).offset(20)
            make.right.equalTo(safeAreaLayoutGuide.snp.right).offset(-20)
        }
        
        addSubview(registerButton)
        registerButton.snp.makeConstraints { make in
            make.top.equalTo(stack.snp.bottom).offset(45)
            make.left.equalTo(safeAreaLayoutGuide.snp.left).offset(20)
            make.right.equalTo(safeAreaLayoutGuide.snp.right).offset(-20)
        }
    }
}
