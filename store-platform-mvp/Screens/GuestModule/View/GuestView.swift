import UIKit

class GuestView: UIView {
    lazy var label = UILabel(text: "Вы еще не авторизованы",
                             font: UIFont.systemFont(ofSize: 14, weight: .semibold),
                             textColor: .black)
    lazy var loginButton = UIButton(text: "Авторизация", preset: .none)
    lazy var registerButton = UIButton(text: "Регистрация", preset: .none)
    
    func configureViews() {
        backgroundColor = .white
        let stack = UIStackView(arrangedSubviews: [label,
                                                   loginButton,
                                                   registerButton],
                                spacing: 5, axis: .vertical, alignment: .fill)
        addSubview(stack)
        stack.snp.makeConstraints { make in
            make.center.equalTo(snp.center)
        }
    }
}
