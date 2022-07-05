import UIKit

class FillBrandDataView: UIView {
    let aboutBrandTitleLabel = UILabel(text: "Информация о бренде", font: nil, textColor: .black)
    let brandNameTextField = UITextField(placeholder: "Название бренда", withUnderline: true, keyboardType: .default)
    let descriptionTextField = UITextField(placeholder: "Краткое описание", withUnderline: true, keyboardType: .default)
    let logoTitleLabel = UILabel(text: "Логотип бренда", font: nil, textColor: .black)
    let deliveryTitleLabel = UILabel(text: "Информация о доставке", font: nil, textColor: .black)
    let deliveryCityTextField = UITextField(placeholder: "Город", withUnderline: true, keyboardType: .default)
    let firstNameTextField = UITextField(placeholder: "Имя", withUnderline: true, keyboardType: .default)
    let lastNameTextField = UITextField(placeholder: "Фамилия", withUnderline: true, keyboardType: .default)
    let patronymicTextField = UITextField(placeholder: "Отчество", withUnderline: true, keyboardType: .default)
    let logoSizeLabel = UILabel(text: "200x50", font: nil, textColor: .systemGray)
    let logoImageView = UIImageView(image: nil, contentMode: .scaleAspectFit, clipToBounds: false)
    let addLogoButton = UIButton()
    let submitButton = UIButton(text: "Отправить", preset: .bottom)
}

extension FillBrandDataView {
    func configureViews() {
        backgroundColor = .white
        aboutBrandTitleLabel.font = Constants.Fonts.itemTitleFont
        logoTitleLabel.font = Constants.Fonts.itemTitleFont
        deliveryTitleLabel.font = Constants.Fonts.itemTitleFont
        
        logoSizeLabel.font = Constants.Fonts.itemDescriptionFont
        
        logoImageView.image = UIImage(systemName: "plus.viewfinder")?.withTintColor(.black, renderingMode: .alwaysOriginal)

        let brandTextFieldsStack = UIStackView(arrangedSubviews: [brandNameTextField, descriptionTextField], spacing: 20, axis: .vertical, alignment: .fill)
        brandTextFieldsStack.distribution = .fillEqually
                
        let brandTextFieldsStackWithTitle = UIStackView(arrangedSubviews: [aboutBrandTitleLabel, brandTextFieldsStack], spacing: 5, axis: .vertical, alignment: .fill)
        
        addSubview(brandTextFieldsStackWithTitle)
        brandTextFieldsStackWithTitle.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide.snp.top)
            make.left.equalTo(snp.left).offset(20)
            make.right.equalTo(snp.right).offset(-20)
        }
        let logoBrandStack = UIStackView(arrangedSubviews: [logoTitleLabel, addLogoButton], spacing: 5, axis: .vertical, alignment: .fill)
        
        addSubview(logoBrandStack)
        logoBrandStack.snp.makeConstraints { make in
            make.top.equalTo(brandTextFieldsStackWithTitle.snp.bottom).offset(20)
            make.left.equalTo(snp.left).offset(20)
        }
        
        addLogoButton.snp.makeConstraints { make in
            make.left.equalTo(snp.left).offset(20)
            make.width.equalTo(200)
            make.height.equalTo(80)
        }
        
        addLogoButton.layer.borderWidth = 1.0
        addLogoButton.layer.borderColor = UIColor.red.cgColor
        
        addLogoButton.addSubview(logoImageView)
        addLogoButton.addSubview(logoSizeLabel)
        
        logoImageView.snp.makeConstraints { make in
            make.center.equalTo(addLogoButton.snp.center)
        }
        
        logoSizeLabel.snp.makeConstraints { make in
            make.top.equalTo(logoImageView.snp.bottom).offset(5)
            make.centerX.equalTo(logoImageView.snp.centerX)
        }
        
        let deliveryTextFieldsStack = UIStackView(arrangedSubviews: [deliveryCityTextField, lastNameTextField, firstNameTextField , patronymicTextField], spacing: 20, axis: .vertical, alignment: .fill)
        deliveryTextFieldsStack.distribution = .fillEqually
        let deliveryStack = UIStackView(arrangedSubviews: [deliveryTitleLabel, deliveryTextFieldsStack], spacing: 5, axis: .vertical, alignment: .fill)
        
        addSubview(deliveryStack)
        deliveryStack.snp.makeConstraints { make in
            make.top.equalTo(logoBrandStack.snp.bottom).offset(20)
            make.left.equalTo(snp.left).offset(20)
            make.right.equalTo(snp.right).offset(-20)
        }
        
        addSubview(submitButton)
        submitButton.snp.makeConstraints { make in
            make.bottom.equalTo(snp.bottom).offset(-100)
            make.centerX.equalTo(snp.centerX)
            make.height.equalTo(40)
            make.width.equalTo(180)
        }
    }
    
    func updateImageConstraints() {
        logoSizeLabel.removeFromSuperview()
        logoImageView.snp.removeConstraints()
        
        logoImageView.snp.makeConstraints { make in
            make.height.equalTo(addLogoButton.snp.height)
            make.width.equalTo(addLogoButton.snp.width)
        }
    }
}
