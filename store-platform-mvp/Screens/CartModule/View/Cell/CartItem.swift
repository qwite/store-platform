import UIKit

class CartItem: UICollectionViewCell {
    static let reuseId = "CartItem"
    
    let brandNameLabel = UILabel(text: nil, font: .systemFont(ofSize: 18, weight: .medium), textColor: .black)
    let clothingNameLabel = UILabel(text: nil, font: .systemFont(ofSize: 15, weight: .regular), textColor: .black)
    let priceLabel = UILabel(text: nil, font: .systemFont(ofSize: 15, weight: .regular), textColor: .black)
    let amountItem = UILabel(text: "Количество 1", font: .systemFont(ofSize: 13, weight: .light), textColor: .black)
    let selectedSizeLabel = UILabel(text: "Размер S", font: .systemFont(ofSize: 13, weight: .light), textColor: .black)
    let imageView = UIImageView(image: UIImage(named: "blue_test"))
}

extension CartItem {
    func configure(item: Item) {
        guard let sizes = item.sizes, let firstPrice = sizes.first?.price else {
            return
        }
        
        brandNameLabel.text = item.brandName
        clothingNameLabel.text = item.clothingName
        priceLabel.text = "\(firstPrice) ₽"
        
        configureViews()
    }
    
    func configureViews() {
        imageView.contentMode = .scaleAspectFit
        
        let itemStack = UIStackView(arrangedSubviews: [brandNameLabel, clothingNameLabel], spacing: 3, axis: .vertical, alignment: .fill)
        let selectedInfo = UIStackView(arrangedSubviews: [amountItem, selectedSizeLabel], spacing: 3, axis: .vertical, alignment: .fill)
        
        let itemWithSelectedStack = UIStackView(arrangedSubviews: [itemStack, selectedInfo], spacing: 10, axis: .vertical, alignment: .fill)
        
        addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.left.equalTo(snp.left)
            make.width.equalTo(163)
            make.height.equalTo(snp.height)
        }
        
        addSubview(itemWithSelectedStack)
        
        itemWithSelectedStack.snp.makeConstraints { make in
            make.left.equalTo(imageView.snp.right).offset(10)
            make.top.equalTo(snp.top)
        }
        
        let bottomStack = UIStackView(arrangedSubviews: [priceLabel], spacing: 0, axis: .vertical, alignment: .fill)
        addSubview(bottomStack)
        
        bottomStack.snp.makeConstraints { make in
            make.bottom.equalTo(snp.bottom)
            make.right.equalTo(snp.right)
        }
    }
}
