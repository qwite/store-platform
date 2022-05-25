import UIKit

class AdCell: UICollectionViewCell {
    static let reuseId: String = "AdCell"
    
    lazy var scrollView = UIScrollView()
    lazy var brandNameLabel = UILabel(text: "", font: UIFont.systemFont(ofSize: 18, weight: .semibold), textColor: .black)
    lazy var clothingNameLabel = UILabel(text: "", font: UIFont.systemFont(ofSize: 15, weight: .regular), textColor: .black)
    lazy var priceLabel = UILabel(text: "", font: UIFont.systemFont(ofSize: 15, weight: .regular), textColor: .black)
    lazy var heartButton = UIButton(text: nil, preset: .icon, iconName: "heart", selectedIconName: "heart.fill")
    
    func configure(with item: Item) {
        self.brandNameLabel.text = item.brandName
        self.clothingNameLabel.text = item.clothingName
        // TODO: fix price
        let price = item.sizes!.first?.price
        self.priceLabel.text = "\(price!) ₽"
        
        if let photos = item.photos {
            configureScrollView(photos: photos, size: CGSize(width: frame.width, height: 170))
        }
        
        configureViews()
    }
    
    private func configureViews() {
        backgroundColor = .white
        brandNameLabel.lineBreakMode = .byWordWrapping
        brandNameLabel.numberOfLines = 0
        
        clothingNameLabel.lineBreakMode = .byWordWrapping
        clothingNameLabel.numberOfLines = 0
        
        let stack = UIStackView(arrangedSubviews: [brandNameLabel, clothingNameLabel, priceLabel],
                                spacing: 3,
                                axis: .vertical,
                                alignment: .leading)
        addSubview(stack)
        
        stack.snp.makeConstraints { make in
            make.top.equalTo(scrollView.snp.bottom).offset(10)
            make.width.equalTo(snp.width)
        }
    }
    
    
    func configureScrollView(photos: [String], size: CGSize) {
        addSubview(scrollView)
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        
        StorageService.sharedInstance.getImagesFromUrls(images: photos, size: size) { [weak self] result in
            switch result {
            case .success(let imageView):
                self?.scrollView.addSubview(imageView)
            case .failure(let error):
                fatalError("\(error)")
            }
        }
        
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(snp.top)
            make.width.equalTo(snp.width)
            make.height.equalTo(170)
        }
        
        scrollView.contentSize = CGSize(width: CGFloat(photos.count) * frame.width,
                                        height: scrollView.frame.height)
    }
}
