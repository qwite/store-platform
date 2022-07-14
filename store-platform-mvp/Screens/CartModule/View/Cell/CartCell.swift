import UIKit

// MARK: - CartItemCellDelegate
protocol CartCellDelegate: AnyObject {
    func didTappedRemoveButton(_ cell: UICollectionViewCell)
}

// MARK: - CartItemCell
class CartCell: UICollectionViewCell {
    static let reuseId = "CartCell"
    weak var delegate: CartCellDelegate?
    
    let brandNameLabel = UILabel(text: nil, font: .systemFont(ofSize: 18, weight: .medium), textColor: .black)
    let clothingNameLabel = UILabel(text: nil, font: .systemFont(ofSize: 15, weight: .regular), textColor: .black)
    let priceLabel = UILabel(text: nil, font: .systemFont(ofSize: 15, weight: .regular), textColor: .black)
    let colorLabel = UILabel(text: nil, font: .systemFont(ofSize: 13, weight: .light), textColor: .black)
    let selectedSizeLabel = UILabel(text: nil, font: .systemFont(ofSize: 13, weight: .light), textColor: .black)
    var imageView = UIImageView()
    let removeButton = UIButton(text: nil, preset: .icon, iconName: "xmark")
}

// MARK: - Public methods
extension CartCell {
    public func configure(cartItem: Cart) {
        guard let firstPhoto = cartItem.item.photos?.first else {
            return
        }
        
        brandNameLabel.text = cartItem.item.brandName.capitalized
        clothingNameLabel.text = cartItem.item.clothingName
        priceLabel.text = "\(cartItem.selectedPrice) ₽"
        colorLabel.text = "Цвет \(cartItem.item.color)"
        selectedSizeLabel.text = "Размер \(cartItem.selectedSize)"
        
        configureViews()
        configureImageView(photo: firstPhoto)
        configureButtons()
    }
}

// MARK: - Private methods
extension CartCell {
    
    private func configureViews() {
        imageView.contentMode = .scaleAspectFit
        
        let itemStack = UIStackView(arrangedSubviews: [brandNameLabel, clothingNameLabel], spacing: 3, axis: .vertical, alignment: .fill)
        let selectedInfo = UIStackView(arrangedSubviews: [selectedSizeLabel, colorLabel], spacing: 3, axis: .vertical, alignment: .fill)
        
        let bottomStack = UIStackView(arrangedSubviews: [priceLabel], spacing: 0, axis: .vertical, alignment: .fill)
        
        let itemWithSelectedStack = UIStackView(arrangedSubviews: [itemStack, selectedInfo, bottomStack], spacing: 10, axis: .vertical, alignment: .fill)
        
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
        
        addSubview(removeButton)
        removeButton.snp.makeConstraints { make in
            make.right.equalTo(snp.right)
            make.top.equalTo(snp.top)
        }
        
    }
    
    private func configureImageView(photo: String) {
        let photoSize = CGSize(width: 163, height: frame.size.height)
        StorageService.sharedInstance.getImagesFromUrls(images: [photo], size: photoSize) { result in
            guard let imageView = try? result.get() else {
                return
            }
            
            debugPrint(self.frame.size.height)
            self.imageView.image = imageView.image
        }
    }
    
    private func configureButtons() {
        removeButton.addTarget(self, action: #selector(removeButtonAction), for: .touchUpInside)
    }
    
    @objc private func removeButtonAction() {
        delegate?.didTappedRemoveButton(self)
    }
}
