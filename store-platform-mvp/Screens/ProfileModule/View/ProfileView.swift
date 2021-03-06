import UIKit

// MARK: - ProfileView
class ProfileView: UIView {
    let profileNameLabel = UILabel(text: "...", font: nil, textColor: .black)
    let profileNameDescription = UILabel(text: "Обзор профиля", font: nil, textColor: .black)
    let labelStack = UIStackView()
    let userOrdersButton = UIButton(text: "Мои заказы", preset: .profile)
    let subscriptionsButton = UIButton(text: "Мои подписки", preset: .profile)

    let communicationWithStoreButton = UIButton(text: "Обращения в магазин", preset: .profile)
    let settingsButton = UIButton(text: "Настройки", preset: .profile)
    let logoutButton = UIButton(text: "Выход", preset: .profile)
}

// MARK: - Public methods
extension ProfileView {
    public func configure() {
        configureViews()
    }
}

// MARK: - Private methods
extension ProfileView {
    private func configureViews() {
        backgroundColor = .white
        profileNameLabel.font = Constants.Fonts.itemTitleFont
        profileNameDescription.font = Constants.Fonts.itemDescriptionFont
    
        labelStack.addArrangedSubview(profileNameLabel)
        labelStack.addArrangedSubview(profileNameDescription)
        
        labelStack.spacing = 5
        labelStack.axis = .vertical
        labelStack.alignment = .fill
        
        addSubview(labelStack)
        labelStack.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide.snp.top).offset(20)
            make.left.equalTo(snp.left).offset(20)
        }
        
        let buttonStack = UIStackView(arrangedSubviews: [userOrdersButton, subscriptionsButton, communicationWithStoreButton, settingsButton, logoutButton],
                                      spacing: 15, axis: .vertical, alignment: .fill)
        
        addSubview(buttonStack)
        
        buttonStack.snp.makeConstraints { make in
            make.top.equalTo(labelStack.snp.bottom).offset(30)
            make.left.equalTo(snp.left).offset(20)
            make.right.equalTo(snp.right).offset(-20)
        }
    }
}
