import UIKit

// TODO: refactor code
extension UIButton {
    enum Preset {
        case customLarge
        case profile
        case select
        case bottom
        case radioButton
        case filterButton
        case clearButton
        case icon
    }
    
    convenience init(text: String?,
                     preset: Preset?,
                     font: UIFont? = nil,
                     iconName: String? = nil,
                     selectedIconName: String? = nil, with symbol: Bool? = false) {
        self.init()
        
        switch preset {
        case .select:
            let customAttributes: [NSAttributedString.Key: Any] = [
                .foregroundColor: UIColor.black,
                .font: UIFont.systemFont(ofSize: 18, weight: .medium)
            ]
            
            let customAttributedText = NSAttributedString(string: text!, attributes: customAttributes)
            self.setAttributedTitle(customAttributedText, for: .normal)
            
            self.titleLabel?.snp.makeConstraints({ make in
                make.left.equalTo(self.snp.left)
            })
            
            if symbol == true {
                let symbolConfiguration = UIImage.SymbolConfiguration(scale: .medium)
                let imageView = UIImageView(image: .init(systemName: "chevron.down",
                                                         withConfiguration: symbolConfiguration)?
                    .withTintColor(.black, renderingMode: .alwaysOriginal))
                
                self.addSubview(imageView)
                                
                imageView.snp.makeConstraints { make in
                    make.right.equalTo(snp.right)
                    make.centerY.equalTo(self.titleLabel!.snp.centerY)
                }
            }
        case .customLarge:
            self.backgroundColor = .black
            
            let customAttributes: [NSAttributedString.Key: Any] = [
                .foregroundColor: UIColor.white,
                .font: UIFont.systemFont(ofSize: 34, weight: .bold)
            ]
            
            let customAttributedText = NSAttributedString(string: text!, attributes: customAttributes)
            self.setAttributedTitle(customAttributedText, for: .normal)
        case .bottom:
            self.layer.cornerRadius = 15
            self.backgroundColor = .black
            let bottomAttributes: [NSAttributedString.Key: Any] = [
                .foregroundColor: UIColor.white,
                .font: UIFont.systemFont(ofSize: 14, weight: .semibold)
            ]
            
            let bottomAttributedText = NSAttributedString(string: text!, attributes: bottomAttributes)
            self.setAttributedTitle(bottomAttributedText, for: .normal)
        case .icon:
            let image = UIImage(systemName: iconName!)
            if let selectedIconName = selectedIconName {
                self.setImage(UIImage(systemName: selectedIconName), for: .selected)
            }
            
            self.setImage(image, for: .normal)
            self.tintColor = .black
        case .profile:
            let profileAttributes: [NSAttributedString.Key: Any] = [
                .foregroundColor: UIColor.black,
                .font: UIFont.systemFont(ofSize: 18, weight: .medium)
            ]
            
            let profileAttributedText = NSAttributedString(string: text!, attributes: profileAttributes)
            self.setAttributedTitle(profileAttributedText, for: .normal)
            
            self.titleLabel!.snp.makeConstraints { make in
                make.left.equalTo(self.snp.left)
            }
            
            let symbolConfiguration = UIImage.SymbolConfiguration(scale: .medium)
            let arrowImageView = UIImageView(image: .init(systemName: "chevron.right",
                                                          withConfiguration: symbolConfiguration)?
                .withTintColor(.black, renderingMode: .alwaysOriginal))
            
            self.addSubview(arrowImageView)
            arrowImageView.snp.makeConstraints { make in
                make.right.equalTo(self.snp.right)
                make.centerY.equalTo(self.titleLabel!.snp.centerY)
            }
        case .radioButton:
            self.init(type: .custom)
            
            let radioButtonAttributes: [NSAttributedString.Key: Any] = [
                .foregroundColor: UIColor.black,
                .font: UIFont.systemFont(ofSize: 18, weight: .regular)
            ]
            
            let radioButtonAttributesText = NSAttributedString(string: text!, attributes: radioButtonAttributes)
            self.setAttributedTitle(radioButtonAttributesText, for: .normal)
        case .filterButton:
            self.init(type: .custom)
            
            guard let titleView = self.titleLabel else {
                return
            }
            
            titleView.snp.makeConstraints { make in
                make.left.equalTo(self.snp.left)
            }
            
            self.snp.makeConstraints { make in
                make.height.equalTo(20)
            }
            
            let filterButtonAttributes: [NSAttributedString.Key: Any] = [
                .foregroundColor: UIColor.black,
                .font: UIFont.systemFont(ofSize: 18, weight: .regular)
            ]
            
            let filterButtonAttributesText = NSAttributedString(string: text!, attributes: filterButtonAttributes)
            self.setAttributedTitle(filterButtonAttributesText, for: .normal)
        case .clearButton:
            guard let titleView = self.titleLabel else {
                return
            }
            
            titleView.snp.makeConstraints { make in
                make.left.equalTo(self.snp.left)
            }
            
            self.snp.makeConstraints { make in
                make.height.equalTo(20)
            }
            
            let filterButtonAttributes: [NSAttributedString.Key: Any] = [
                .foregroundColor: UIColor.systemGray,
                .font: UIFont.systemFont(ofSize: 18, weight: .regular)
            ]
            
            let filterButtonAttributesText = NSAttributedString(string: text!, attributes: filterButtonAttributes)
            self.setAttributedTitle(filterButtonAttributesText, for: .normal)
        case .none:
            
            let defaultAttributes: [NSAttributedString.Key: Any] = [
                .foregroundColor: UIColor.black,
                .font: UIFont.systemFont(ofSize: 14, weight: .medium)
            ]
            
            let defaultAttributedText = NSAttributedString(string: text!, attributes: defaultAttributes)
            self.setAttributedTitle(defaultAttributedText, for: .normal)
        }
        
    }
}
