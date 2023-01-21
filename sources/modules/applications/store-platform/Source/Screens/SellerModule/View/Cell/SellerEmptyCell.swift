import UIKit

class SellerEmptyCell: UICollectionViewCell {
    static let reuseId = "SellerEmpty"
    let label = UILabel(text: nil, font: nil, textColor: .black)
}

extension SellerEmptyCell {
    func configure() {
        
        label.text = "Пока здесь нет товаров! Добавьте товар для просмотра статистики"
        label.font = Constants.Fonts.itemTitleFont
        configureViews()
        
    }
    
    func configureViews() {
        addSubview(label)
        label.snp.makeConstraints { make in
            make.top.equalTo(snp.top)
            make.left.equalTo(snp.left)
            make.width.equalTo(snp.width)
        }
    }
}
