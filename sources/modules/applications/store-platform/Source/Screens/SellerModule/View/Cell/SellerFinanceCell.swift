import UIKit

class SellerFinanceCell: UICollectionViewCell {
    static let reuseId = "SellerFinance"
    let titleLabel = UILabel(text: "За этот месяц заработано", font: nil, textColor: .black)
    let totalPriceLabel = UILabel(text: nil, font: nil, textColor: .black)
}

extension SellerFinanceCell {
    func configure(totalPrice: Int) {
        self.totalPriceLabel.text = "\(totalPrice) ₽"
        
        configureViews()
    }
    
    func configureViews() {
        titleLabel.font = Constants.Fonts.itemTitleFont
        totalPriceLabel.font = Constants.Fonts.itemDescriptionFont
        
        let stack = UIStackView(arrangedSubviews: [titleLabel, totalPriceLabel],
                                spacing: 10,
                                axis: .vertical,
                                alignment: .fill)
        stack.distribution = .fill
        
        addSubview(stack)
        
        stack.snp.makeConstraints { make in
            make.top.equalTo(snp.top)
            make.left.equalTo(snp.left)
        }
    }
    
    func itemsNotExist() {
        let label = UILabel(text: "В данный момент просмотр финансов недоступен",
                            font: Constants.Fonts.itemDescriptionFont,
                            textColor: .black)
        addSubview(label)
        label.snp.makeConstraints { make in
            make.top.equalTo(snp.top)
            make.left.equalTo(snp.left)
            make.width.equalTo(snp.width)
        }
    }
}
