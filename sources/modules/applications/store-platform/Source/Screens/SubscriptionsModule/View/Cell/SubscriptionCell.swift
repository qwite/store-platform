import UIKit

protocol SubscriptionCellDelegate: AnyObject {
    func didTappedRemoveButton(_ cell: UICollectionViewCell)
}

class SubscriptionCell: UICollectionViewCell {
    weak var delegate: SubscriptionCellDelegate?
    static let reuseId = "Subscription"
    let brandNameLabel = UILabel(text: nil, font: nil, textColor: .black)
    let brandDescriptionLabel = UILabel(text: "Бренд одежды", font: Constants.Fonts.itemDescriptionFont, textColor: .black)
    let removeButton = UIButton(text: "", preset: .icon, iconName: "xmark")
}

extension SubscriptionCell {
    func configure(brandName: String) {
        brandNameLabel.text = brandName.capitalized
        brandNameLabel.font = Constants.Fonts.itemTitleFont
        
        configureViews()
        configureButtons()
    }
}

extension SubscriptionCell {
    private func configureViews() {
        let stack = UIStackView(arrangedSubviews: [brandNameLabel, brandDescriptionLabel], spacing: 3, axis: .vertical, alignment: .fill)
        addSubview(stack)
        stack.snp.makeConstraints { make in
            make.top.equalTo(snp.top)
            make.left.equalTo(snp.left)
        }
        
        addSubview(removeButton)
        removeButton.snp.makeConstraints { make in
            make.top.equalTo(snp.top)
            make.right.equalTo(snp.right)
            make.centerY.equalTo(brandNameLabel.snp.centerY)
            
        }
    }
    
    private func configureButtons() {
        removeButton.addTarget(self, action: #selector(removeButtonAction), for: .touchUpInside)
    }
    
    @objc private func removeButtonAction() {
        delegate?.didTappedRemoveButton(self)
    }
}
