import UIKit

// MARK: - WelcomePageView
class WelcomePageView: UIView {
    
    // MARK: Properties
    let onboardingImage = UIImageView(image: UIImage(named: "person-raising-money"))
    let titleLabel = UILabel(text: "Создай свой бренд", font: nil, textColor: .black)
    
    let statTitleLabel = UILabel(text: "Отслеживай статистику", font: nil, textColor: .black)
    let statDescriptionLabel = UILabel(text: "Детальная статистика посещений и продаж \nваших товаров.", font: nil, textColor: .black)
    
    let productTitleLabel = UILabel(text: "Управляй товарами", font: nil, textColor: .black)
    let productDescriptionLabel = UILabel(text: "Добавляй. Изменяй. Редактируй.", font: nil, textColor: .black)
    
    let communicationTitleLabel = UILabel(text: "Взаимодействуй с клиентами", font: nil, textColor: .black)
    let communicationDescriptionLabel = UILabel(text: "Мессенджер для общения с Вашими покупателями.", font: nil, textColor: .black)
    
    let button = UIButton(text: "Продолжить", preset: .bottom)
}

// MARK: - Public methods
extension WelcomePageView {
    func configure() {
        configureViews()
    }
}

// MARK: - Private methods
extension WelcomePageView {
    private func configureViews() {
        backgroundColor = .white
        
        addSubview(onboardingImage)
        
        onboardingImage.snp.makeConstraints { make in
            make.top.equalTo(snp.top)
            make.left.equalTo(snp.left)
            make.right.equalTo(snp.right)
            make.height.equalTo(snp.height).dividedBy(2.5)
        }
        
        titleLabel.font = Constants.Fonts.mainTitleFont
        statTitleLabel.font = Constants.Fonts.itemTitleFont
        statDescriptionLabel.font = Constants.Fonts.itemDescriptionFont
        
        let titleStack = UIStackView(arrangedSubviews: [titleLabel], spacing: 0, axis: .vertical, alignment: .fill)
        addSubview(titleStack)
        
        titleStack.snp.makeConstraints { make in
            make.top.equalTo(onboardingImage.snp.bottom).offset(20)
            make.left.equalTo(snp.left).offset(20)
        }
        statDescriptionLabel.numberOfLines = 0
        
        let statTitleDescriptionStack = UIStackView(arrangedSubviews: [statTitleLabel, statDescriptionLabel], spacing: 3, axis: .vertical, alignment: .fill)
        
        addSubview(statTitleDescriptionStack)
        
        statTitleDescriptionStack.snp.makeConstraints { make in
            make.top.equalTo(titleStack.snp.bottom).offset(20)
            make.left.equalTo(titleStack.snp.left)
            make.right.equalTo(snp.right).offset(-20)
        }
        
        productDescriptionLabel.numberOfLines = 0
        let productTitleDescriptionStack = UIStackView(arrangedSubviews: [productTitleLabel, productDescriptionLabel], spacing: 3, axis: .vertical, alignment: .fill)

        productTitleLabel.font = Constants.Fonts.itemTitleFont
        productDescriptionLabel.font = Constants.Fonts.itemDescriptionFont
        
        addSubview(productTitleDescriptionStack)
        productTitleDescriptionStack.snp.makeConstraints { make in
            make.top.equalTo(statTitleDescriptionStack.snp.bottom).offset(20)
            make.left.equalTo(titleStack.snp.left)
            make.right.equalTo(snp.right).offset(-20)
        }
                
        communicationDescriptionLabel.numberOfLines = 0
        let communicationStack = UIStackView(arrangedSubviews: [communicationTitleLabel, communicationDescriptionLabel], spacing: 3, axis: .vertical, alignment: .fill)
        
        communicationTitleLabel.font = Constants.Fonts.itemTitleFont
        communicationDescriptionLabel.font = Constants.Fonts.itemDescriptionFont
        
        addSubview(communicationStack)
        communicationStack.snp.makeConstraints { make in
            make.top.equalTo(productTitleDescriptionStack.snp.bottom).offset(20)
            make.left.equalTo(titleStack.snp.left)
            make.right.equalTo(snp.right).offset(-20)
        }
        
        addSubview(button)
        button.snp.makeConstraints { make in
            make.bottom.equalTo(snp.bottom).offset(-100)
            make.centerX.equalTo(snp.centerX)
            make.height.equalTo(40)
            make.width.equalTo(180)
        }
    }
}
