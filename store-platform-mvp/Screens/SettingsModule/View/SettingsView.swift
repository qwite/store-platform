import UIKit

class SettingsView: UIView {
    let oldPasswordTextField = UITextField(placeholder: "Введите данные",  withUnderline: true, keyboardType: .default, isSecureTextEntry: true)
    let newPasswordTextField = UITextField(placeholder: "Введите данные", withUnderline: true, keyboardType: .default, isSecureTextEntry: true)
    let repeatNewPasswordTextField = UITextField(placeholder: "Введите данные", withUnderline: true, keyboardType: .default, isSecureTextEntry: true)
    
    let saveDataButton = UIButton(text: "Сохранить данные", preset: .bottom)

}

extension SettingsView {
    func configure() {
        self.configureViews()
    }
}

extension SettingsView {
    func configureViews() {
        backgroundColor = .white
        
        let profileHintFont: UIFont = .systemFont(ofSize: 12, weight: .regular)
        let profileHintColor: UIColor = UIColor(red: 0.762, green: 0.762, blue: 0.762, alpha: 1)
        
        let oldPasswordDescriptionLabel = UILabel(text: "Старый пароль", font: profileHintFont, textColor: profileHintColor)
        let oldPasswordStack = UIStackView(arrangedSubviews: [oldPasswordDescriptionLabel, oldPasswordTextField], spacing: 2, axis: .vertical, alignment: .fill)
        
        let newPasswordDescriptionLabel = UILabel(text: "Новый пароль", font: profileHintFont, textColor: profileHintColor)
        let newPasswordStack = UIStackView(arrangedSubviews: [newPasswordDescriptionLabel, newPasswordTextField], spacing: 2, axis: .vertical, alignment: .fill)
        
        let newPasswordRepeatDescriptionLabel = UILabel(text: "Повторите новый пароль", font: profileHintFont, textColor: profileHintColor)
        let newPasswordRepeatStack = UIStackView(arrangedSubviews: [newPasswordRepeatDescriptionLabel, repeatNewPasswordTextField], spacing: 2, axis: .vertical, alignment: .fill)
        
        let stack = UIStackView(arrangedSubviews: [oldPasswordStack, newPasswordStack, newPasswordRepeatStack], spacing: 20, axis: .vertical, alignment: .fill)
        
        addSubview(stack)
        stack.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide.snp.top)
            make.left.equalTo(snp.left).offset(20)
            make.right.equalTo(snp.right).offset(-20)
        }
        
        addSubview(saveDataButton)
        saveDataButton.snp.makeConstraints { make in
            make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom).offset(-40)
            make.height.equalTo(34)
            make.width.equalTo(170)
            make.centerX.equalTo(snp.centerX)
        }
        
        
    }
}
