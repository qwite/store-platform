import UIKit

// MARK: - GuestView
class GuestView: UIView {
    // MARK: Properties
    let imageView = UIImageView()
    lazy var title = UILabel(text: "Требуется авторизация",
                             font: Constants.Fonts.mainTitleFont,
                             textColor: .black)
    let descriptionLabel = UILabel(text: nil, font: nil, textColor: .black)
    
    lazy var loginButton = UIButton(text: "Авторизация", preset: .none)
    lazy var registerButton = UIButton(text: "Регистрация", preset: .none)
}

// MARK: - Public methods
extension GuestView {
    public func configure() {
        configureViews()
    }
}

// MARK: - Private methods
extension GuestView {
    private func configureViews() {
        imageView.image = UIImage(named: "guest-illustration")
        
        descriptionLabel.text = "Для этого действия требуется авторизация.\nАвторизуйтесь в системе для использования полного функционала"
        descriptionLabel.font = Constants.Fonts.itemDescriptionFont
        descriptionLabel.numberOfLines = 0
        
        backgroundColor = .white
        
        let stack = UIStackView(arrangedSubviews: [title,
                                                   descriptionLabel
                                                   ],
                                spacing: 10, axis: .vertical, alignment: .fill)
        addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide.snp.top)
            make.left.equalTo(snp.left)
            make.right.equalTo(snp.right)
            make.height.equalTo(snp.height).dividedBy(2.3)
        }
        
        addSubview(stack)
        stack.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(10)
            make.left.equalTo(snp.left).offset(20)
            make.right.equalTo(snp.right).offset(-20)
        }
        
        let loginStack = UIStackView(arrangedSubviews: [loginButton, registerButton], spacing: 5, axis: .vertical, alignment: .fill)
        addSubview(loginStack)
        loginStack.snp.makeConstraints { make in
            make.top.equalTo(stack.snp.bottom).offset(30)
            make.centerX.equalTo(snp.centerX)
        }
    }
}
