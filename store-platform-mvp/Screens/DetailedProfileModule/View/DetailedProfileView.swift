import UIKit

// MARK: - DetailedProfileView
class DetailedProfileView: UIView {
    // MARK: Properties
    let firstNameTextField = UITextField(placeholder: "Имя", withUnderline: true, keyboardType: .default)
    let lastNameTextField = UITextField(placeholder: "Фамилия", withUnderline: true, keyboardType: .default)
    let emailTextField = UITextField(placeholder: "Почта",  withUnderline: true, keyboardType: .default)
    let phoneTextField = UITextField(placeholder: "",  withUnderline: true, keyboardType: .default)
    
    let deliveryCityTextField = UITextField(placeholder: "", withUnderline: true,  keyboardType: .default)
    let deliveryStreetTextField = UITextField(placeholder: "", withUnderline: true,  keyboardType: .default)
    let deliveryHouseTextField = UITextField(placeholder: "", withUnderline: true,  keyboardType: .default)
    let deliveryApartmentTextField = UITextField(placeholder: "", withUnderline: true,  keyboardType: .default)
    let deliveryPostalCodeTextField = UITextField(placeholder: "", withUnderline: true,  keyboardType: .default)
    
    let saveDataButton = UIButton(text: "Сохранить данные", preset: .bottom)
}

// MARK: - Public methods
extension DetailedProfileView {
    public func configure(data: UserData) {
        configureViews()
        
        firstNameTextField.text = data.firstName
        lastNameTextField.text = data.lastName
        emailTextField.text = data.email
        
        guard let details = data.details else { return }
        
        phoneTextField.text = details.phone
    
        deliveryCityTextField.text = details.city
        deliveryStreetTextField.text = details.street
        deliveryHouseTextField.text = details.house
        deliveryApartmentTextField.text = details.apartment
        deliveryPostalCodeTextField.text = details.postalCode
    }
}

extension DetailedProfileView {
    private func configureViews() {
        backgroundColor = .white
        
        firstNameTextField.isEnabled = false
        lastNameTextField.isEnabled = false
        emailTextField.isEnabled = false
        
        let profileHintFont: UIFont = .systemFont(ofSize: 12, weight: .regular)
        let profileHintColor: UIColor = UIColor(red: 0.762, green: 0.762, blue: 0.762, alpha: 1)
        
        let profileTitleLabel = UILabel(text: "Личные данные", font: Constants.Fonts.itemTitleFont, textColor: .black)
        
        let firstNameDescriptionLabel = UILabel(text: "Имя", font: profileHintFont, textColor: profileHintColor)
        let firstNameStack = UIStackView(arrangedSubviews: [firstNameDescriptionLabel, firstNameTextField], spacing: 2, axis: .vertical, alignment: .fill)
        
        let lastNameDescriptionLabel = UILabel(text: "Фамилия", font: profileHintFont, textColor: profileHintColor)
        let lastNameStack = UIStackView(arrangedSubviews: [lastNameDescriptionLabel, lastNameTextField], spacing: 2, axis: .vertical, alignment: .fill)
        
        let emailDescriptionLabel = UILabel(text: "Электронная почта", font: profileHintFont, textColor: profileHintColor)
        let emailStack = UIStackView(arrangedSubviews: [emailDescriptionLabel, emailTextField], spacing: 2, axis: .vertical, alignment: .fill)
        
        let phoneNumberDescriptionLabel = UILabel(text: "Номер телефона", font: profileHintFont, textColor: profileHintColor)
        let phoneNumberStack = UIStackView(arrangedSubviews: [phoneNumberDescriptionLabel, phoneTextField], spacing: 2, axis: .vertical, alignment: .fill)
        
        let personalDataFieldsStack = UIStackView(arrangedSubviews: [firstNameStack, lastNameStack, emailStack, phoneNumberStack], spacing: 10, axis: .vertical, alignment: .fill)
        let personalDataStack = UIStackView(arrangedSubviews: [profileTitleLabel, personalDataFieldsStack], spacing: 20, axis: .vertical, alignment: .fill)
        
        addSubview(personalDataStack)
        personalDataStack.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide.snp.top)
            make.left.equalTo(snp.left).offset(20)
            make.right.equalTo(snp.right).offset(-20)
        }
        
        let deliveryTitleLabel = UILabel(text: "Доставка", font: Constants.Fonts.itemTitleFont, textColor: .black)
        
        let deliveryCityHintLabel = UILabel(text: "Город", font: profileHintFont, textColor: profileHintColor)
        let deliveryCityStack = UIStackView(arrangedSubviews: [deliveryCityHintLabel, deliveryCityTextField], spacing: 2, axis: .vertical, alignment: .fill)
        
        let deliveryStreetHintLabel = UILabel(text: "Улица", font: profileHintFont, textColor: profileHintColor)
        let deliveryStreetStack = UIStackView(arrangedSubviews: [deliveryStreetHintLabel, deliveryStreetTextField], spacing: 2, axis: .vertical, alignment: .fill)
        
        let deliveryHouseHintLabel = UILabel(text: "Дом", font: profileHintFont, textColor: profileHintColor)
        let deliveryHouseStack = UIStackView(arrangedSubviews: [deliveryHouseHintLabel, deliveryHouseTextField], spacing: 2, axis: .vertical, alignment: .fill)
        
        let deliveryApartmentHintLabel = UILabel(text: "Квартира", font: profileHintFont, textColor: profileHintColor)
        let deliveryApartmentStack = UIStackView(arrangedSubviews: [deliveryApartmentHintLabel, deliveryApartmentTextField], spacing: 2, axis: .vertical, alignment: .fill)
        
        let deliveryPostalCodeHintLabel = UILabel(text: "Индекс", font: profileHintFont, textColor: profileHintColor)
        let deliveryPostalStack = UIStackView(arrangedSubviews: [deliveryPostalCodeHintLabel, deliveryPostalCodeTextField], spacing: 2, axis: .vertical, alignment: .fill)
        
        let deliveryFieldsStack = UIStackView(arrangedSubviews: [deliveryCityStack, deliveryStreetStack, deliveryHouseStack, deliveryApartmentStack, deliveryPostalStack], spacing: 10, axis: .vertical, alignment: .fill)
        let deliveryStack = UIStackView(arrangedSubviews: [deliveryTitleLabel, deliveryFieldsStack], spacing: 20, axis: .vertical, alignment: .fill)
        
        addSubview(deliveryStack)
        deliveryStack.snp.makeConstraints { make in
            make.top.equalTo(personalDataStack.snp.bottom).offset(20)
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
