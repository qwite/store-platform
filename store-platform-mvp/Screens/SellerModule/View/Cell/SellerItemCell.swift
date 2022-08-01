import UIKit

class SellerItemCell: UICollectionViewCell {
    static let reuseId = "SellerItem"
    let clothingImageView = UIImageView()
    let clothingNameLabel = UILabel(text: nil, font: nil, textColor: .black)
    let sizesLabel = UILabel(text: nil, font: nil, textColor: .black)
    let viewsCounterLabel = UILabel(text: nil, font: nil, textColor: .black)
    let config = UIImage.SymbolConfiguration(weight: .bold)
    let eyeImageView = UIImageView(image: UIImage(systemName: "eye", withConfiguration: UIImage.SymbolConfiguration(scale: .small))?.withTintColor(.systemGray, renderingMode: .alwaysOriginal))
}

extension SellerItemCell {
    func configure(itemViews: Views) {
        guard let firstPhotoUrl = itemViews.item.photos?.first else {
            fatalError("sizes not exist")
        }
        
        let sizes = itemViews.item.sizes
        
        if clothingNameLabel.text == nil {
            configureViews()
        }
        
        self.sizesLabel.text = prepareSizes(sizes: sizes)
        self.clothingNameLabel.text = itemViews.item.clothingName
        self.viewsCounterLabel.text = "\(itemViews.views)"
        prepareImage(imageUrl: firstPhotoUrl) { image in
            self.clothingImageView.image = image
        }
        

    }
    
    func configureViews() {
        self.clothingNameLabel.font = Constants.Fonts.itemTitleFont
        self.sizesLabel.font = Constants.Fonts.itemDescriptionFont
        clothingImageView.contentMode = .scaleAspectFit
        let imageStack = UIStackView(arrangedSubviews: [clothingImageView], spacing: 0, axis: .vertical, alignment: .fill)
        let labelsStack = UIStackView(arrangedSubviews: [clothingNameLabel, sizesLabel], spacing: 2, axis: .vertical, alignment: .fill)
        let viewsStack = UIStackView(arrangedSubviews: [eyeImageView, viewsCounterLabel], spacing: 2, axis: .horizontal, alignment: .leading)
        viewsStack.distribution = .equalSpacing
        
        let stack = UIStackView(arrangedSubviews: [imageStack, labelsStack, viewsStack], spacing: 2, axis: .vertical, alignment: .fill)
    
        addSubview(stack)

        stack.snp.makeConstraints { make in
            make.edges.equalTo(snp.edges)
            make.width.equalTo(snp.width)
            make.height.equalTo(snp.height)
        }
        
        imageStack.snp.makeConstraints { make in
            make.width.equalTo(stack.snp.width)
            make.height.equalTo(stack.snp.height).dividedBy(2)
        }
        
        let eyeImageWidth = eyeImageView.frame.size.width
        viewsCounterLabel.snp.makeConstraints { make in
            make.width.equalTo(stack.snp.width).offset(-eyeImageWidth)
        }
    }
    
    func itemsNotExist() {
        let label = UILabel(text: "Добавьте товары для просмотра функционала.",
                            font: Constants.Fonts.itemDescriptionFont,
                            textColor: .black)
        addSubview(label)
        label.snp.makeConstraints { make in
            make.top.equalTo(snp.top)
            make.left.equalTo(snp.left)
        }
    }
    
    // MARK: Private methods
    private func prepareSizes(sizes: [Size]) -> String {
        let availableSizes = sizes.map({ $0.size })
        let sizes: String = availableSizes.joined(separator: ", ")
        
        return sizes
    }
    
    private func prepareImage(imageUrl: String, completion: @escaping (UIImage) -> ()) {
        StorageService.sharedInstance.getImageFromUrl(imageUrl: imageUrl) { result in
            switch result {
            case .success(let data):
                guard let image = UIImage(data: data) else {
                    fatalError()
                }
                
                completion(image)
            case .failure(let error):
                debugPrint(error)
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
}
