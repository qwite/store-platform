import UIKit

// MARK: - DetailedOrderView
class DetailedOrderView: UIView {
    
    // MARK: Properties
    let statusLabel = UILabel(text: nil, font: nil, textColor: .black)
    let userFullNameLabel = UILabel(text: nil, font: nil, textColor: .black)
    let userPhoneNumberLabel = UILabel(text: nil, font: nil, textColor: .black)
    let userDeliveryAddressLabel = UILabel(text: nil, font: nil, textColor: .black)
    let orderReceipt = UILabel(text: "Чек", font: Constants.Fonts.itemTitleFont, textColor: .systemBlue)
    let communicationWithBrandButton = UIButton(text: "Связаться с продацом", preset: .bottom)
    let priceLabel = UILabel(text: nil, font: nil, textColor: .black)
    
    let reviewDescriptionLabel = UILabel(text: nil, font: nil, textColor: .black)
    let cosmosView = UIView()
    let reviewTextField = UITextField(placeholder: "Ваш отзыв", withUnderline: true, keyboardType: .default)
    let reviewsStack = UIStackView()
    let addReviewButton = UIButton(text: "Добавить отзыв", preset: .bottom)
}

// MARK: - DetailedOrderView Public methods
extension DetailedOrderView {
    func configure(order: Order) {
        configureStatusLabel(status: order.status)
        userFullNameLabel.text = order.userFullName
        userPhoneNumberLabel.text = order.userPhoneNumber
        userDeliveryAddressLabel.text = order.userShippingAddress
        priceLabel.text = "\(order.item.selectedPrice) ₽"
        
        self.configureStars()
        self.configureViews()
        self.showRatingFields()
    }
}

// MARK: - Private methods
extension DetailedOrderView {
    private func configureStars() {
        // TODO("Create stars view.")

        fatalError("Create stars view.")
    }
    
    private func showRatingFields() {
        addSubview(addReviewButton)
        addReviewButton.snp.makeConstraints { make in
            make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom).offset(-20)
            make.width.equalTo(212)
            make.height.equalTo(34)
            make.centerX.equalTo(snp.centerX)
        }
        
        reviewsStack.isHidden = false
        communicationWithBrandButton.isHidden = false
    }
    
    private func configureViews() {
        backgroundColor = .white
        statusLabel.font = .systemFont(ofSize: 18, weight: .bold)
        
        userDeliveryAddressLabel.numberOfLines = 0
        
        let recipientTitle = UILabel(text: "Получатель", font: Constants.Fonts.itemTitleFont, textColor: .black)
        let deliveryTitle = UILabel(text: "Доставка", font: Constants.Fonts.itemTitleFont, textColor: .black)
        
        let userInfoStack = UIStackView(arrangedSubviews: [userFullNameLabel, userPhoneNumberLabel], spacing: 5, axis: .vertical, alignment: .fill)
        let recipientStack = UIStackView(arrangedSubviews: [recipientTitle, userInfoStack], spacing: 15, axis: .vertical, alignment: .fill)
        
        let deliveryStack = UIStackView(arrangedSubviews: [deliveryTitle, userDeliveryAddressLabel], spacing: 15, axis: .vertical, alignment: .fill)
        
        addSubview(statusLabel)
        statusLabel.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide.snp.top).offset(40)
            make.centerX.equalTo(snp.centerX)
        }
        
        addSubview(recipientStack)
        recipientStack.snp.makeConstraints { make in
            make.top.equalTo(statusLabel.snp.bottom).offset(30)
            make.left.equalTo(snp.left).offset(20)
            make.right.equalTo(snp.right).offset(-20)
        }
        
        addSubview(deliveryStack)
        deliveryStack.snp.makeConstraints { make in
            make.top.equalTo(recipientStack.snp.bottom).offset(20)
            make.left.equalTo(snp.left).offset(20)
            make.right.equalTo(snp.right).offset(-20)
        }
        
        let paidTitleLabel = UILabel(text: "Оплата", font: Constants.Fonts.itemTitleFont, textColor: .black)
        let paidDescriptionLabel = UILabel(text: "Оплачено", font: nil, textColor: .black)
        
        let paidDescriptionStack = UIStackView(arrangedSubviews: [paidDescriptionLabel, priceLabel], spacing: 5, axis: .horizontal, alignment: .fill)
        let paidStack = UIStackView(arrangedSubviews: [paidTitleLabel, paidDescriptionStack], spacing: 15, axis: .vertical, alignment: .fill)
        
        addSubview(paidStack)
        paidStack.snp.makeConstraints { make in
            make.top.equalTo(deliveryStack.snp.bottom).offset(20)
            make.left.equalTo(snp.left).offset(20)
            make.right.equalTo(snp.right).offset(-20)
        }
        
        addSubview(orderReceipt)
        orderReceipt.snp.makeConstraints { make in
            make.top.equalTo(paidStack.snp.bottom).offset(20)
            make.left.equalTo(snp.left).offset(20)
            make.right.equalTo(snp.right).offset(-20)
        }
        
        let descWithStarsStack = UIStackView(arrangedSubviews: [reviewDescriptionLabel, cosmosView], spacing: 5, axis: .vertical, alignment: .fill)
        
        reviewDescriptionLabel.text = "Будем рады, если Вы оставите отзыв 😎"
        reviewDescriptionLabel.font = Constants.Fonts.itemTitleFont
        reviewsStack.addArrangedSubview(descWithStarsStack)
        reviewsStack.addArrangedSubview(reviewTextField)
        reviewsStack.spacing = 5
        reviewsStack.alignment = .fill
        reviewsStack.axis = .vertical
        
        reviewsStack.isHidden = true
        
        addSubview(reviewsStack)
        reviewsStack.snp.makeConstraints { make in
            make.top.equalTo(orderReceipt.snp.bottom).offset(20)
            make.left.equalTo(snp.left).offset(20)
            make.right.equalTo(snp.right).offset(-20)
        }
        
        addSubview(communicationWithBrandButton)
        communicationWithBrandButton.snp.makeConstraints { make in
            make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom).offset(-20)
            make.width.equalTo(212)
            make.height.equalTo(34)
            make.centerX.equalTo(snp.centerX)
        }
        
        
    }
    
    private func configureStatusLabel(status: Order.Status.RawValue) {
        var resultText: String = ""
        
        switch status {
        case "process":
            resultText = "В обработке"
        case "shipped":
            resultText = "Отправлен"
        case "delivered":
            resultText = "Доставлен"
        default:
            break
        }
        
        statusLabel.text = resultText
    }
}
