import UIKit

// MARK: - AdCellDelegate Protocol
protocol AdCellDelegate: AnyObject {
    func didFetchFavoriteState(item: Item)
    func didTappedLikeButton(_ adCell: AdCell)
    func didUntappedLikeButton(_ adCell: AdCell)
}

//MARK: - UICollectionViewCell
class AdCell: UICollectionViewCell {
    static let reuseId: String = "AdCell"
    weak var delegate: AdCellDelegate?
    
    // MARK: Properties
    lazy var scrollView = UIScrollView()
    lazy var brandNameLabel = UILabel(text: "", font: UIFont.systemFont(ofSize: 18, weight: .semibold), textColor: .black)
    lazy var clothingNameLabel = UILabel(text: "", font: UIFont.systemFont(ofSize: 15, weight: .regular), textColor: .black)
    lazy var priceLabel = UILabel(text: "", font: UIFont.systemFont(ofSize: 15, weight: .regular), textColor: .black)
    lazy var favoriteButton = UIButton(text: nil, preset: .icon, iconName: "heart", selectedIconName: "heart.fill")
    
    var favoriteState: FavoriteState? {
        didSet {
            guard let favoriteState = favoriteState else {
                return
            }
            
            configureFavoriteButton(state: favoriteState)
        }
    }
    
    // MARK: prepareForReuse
    override func prepareForReuse() {
        super.prepareForReuse()
        self.brandNameLabel.text = nil
        self.clothingNameLabel.text = nil
        self.priceLabel.text = nil
        self.scrollView.subviews.forEach({ $0.removeFromSuperview() })
        self.favoriteState = nil
    }
}

// MARK: - Public functions
extension AdCell {
    public func configure(with item: Item) {
        self.brandNameLabel.text = item.brandName.capitalized
        self.clothingNameLabel.text = item.clothingName
        
        // Show first price from available sizes
        if let firstPrice = item.sizes.first?.price {
            self.priceLabel.text = "\(firstPrice) ₽"
        }

        if let photos = item.photos {
            configureScrollView(photos: photos, size: CGSize(width: frame.width, height: 170))
        }
        
        configureViews()
        configureButtons()
        
        delegate?.didFetchFavoriteState(item: item)
    }
}

// MARK: - Private functions
extension AdCell {
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
    
    private func configureScrollView(photos: [String], size: CGSize) {
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
        
        addSubview(favoriteButton)
        
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(snp.top)
            make.width.equalTo(snp.width)
            make.height.equalTo(170)
        }
        
        favoriteButton.snp.makeConstraints { make in
            make.top.equalTo(snp.top)
            make.right.equalTo(snp.right)
        }
        
        scrollView.contentSize = CGSize(width: CGFloat(photos.count) * frame.width,
                                        height: scrollView.frame.height)
    }
    
    private func configureFavoriteButton(state: FavoriteState) {
        switch state {
        case .none:
            break
        case .liked:
            favoriteButton.isSelected = true
        case .unliked:
            favoriteButton.isSelected = false
        }
    }
    
    private func configureButtons() {
        favoriteButton.addTarget(self, action: #selector(favoriteButtonTapped), for: .touchUpInside)
    }
    
    @objc private func favoriteButtonTapped() {
        if favoriteButton.isSelected {
            favoriteButton.isSelected = false
            favoriteState = .unliked
            delegate?.didUntappedLikeButton(self)
        } else {
            favoriteButton.isSelected = true
            favoriteState = .liked
            delegate?.didTappedLikeButton(self)
        }
    }
}

// MARK: - LikeState
extension AdCell {
    enum FavoriteState {
        case none
        case liked
        case unliked
    }
}
