import UIKit

// MARK: - FavoriteCellDelegate
protocol FavoriteCellDelegate: AnyObject {
    func didTappedAddButton(_ favoriteCell: FavoriteCell)
    func didTappedRemoveButton(_ favoriteCell: FavoriteCell)
}

// MARK: - FavoriteCell
class FavoriteCell: UICollectionViewCell {
    
    // MARK: Properties
    weak var delegate: FavoriteCellDelegate?
    static let reuseId: String = "Favorite"
    lazy var scrollView = UIScrollView()
    lazy var brandNameLabel = UILabel(text: "", font: UIFont.systemFont(ofSize: 18, weight: .semibold), textColor: .black)
    lazy var clothingNameLabel = UILabel(text: "", font: UIFont.systemFont(ofSize: 15, weight: .regular), textColor: .black)
    lazy var priceLabel = UILabel(text: "", font: UIFont.systemFont(ofSize: 15, weight: .regular), textColor: .black)
    lazy var removeButton = UIButton(text: nil, preset: .icon, iconName: "xmark")
    lazy var addToCartButton = UIButton(text: "Добавить в корзину", preset: .none)
    var likeState: LikeState?
}

// MARK: - Public methods
extension FavoriteCell {
    func configure(with item: Item) {
        self.brandNameLabel.text = item.brandName.capitalized
        self.clothingNameLabel.text = item.clothingName
        // TODO: fix price
        let price = item.sizes!.first?.price
        self.priceLabel.text = "\(price!) ₽"
        if let photos = item.photos, let firstPhoto = photos.first {
            configureScrollView(photos: [firstPhoto], size: CGSize(width: frame.width, height: 170))
        }
        
        configureViews()
        configureButtons()
    }
}

// MARK: - Private methods
extension FavoriteCell {
    private func configureViews() {
        backgroundColor = .white
        brandNameLabel.lineBreakMode = .byWordWrapping
        brandNameLabel.numberOfLines = 0
        
        clothingNameLabel.lineBreakMode = .byWordWrapping
        clothingNameLabel.numberOfLines = 0
        
        let stack = UIStackView(arrangedSubviews: [brandNameLabel, clothingNameLabel, priceLabel, addToCartButton],
                                spacing: 3,
                                axis: .vertical,
                                alignment: .leading)
        addSubview(stack)
        
        stack.snp.makeConstraints { make in
            make.top.equalTo(scrollView.snp.bottom).offset(10)
            make.width.equalTo(snp.width)
        }
        
        removeButton.snp.makeConstraints { make in
            make.top.equalTo(snp.top)
            make.right.equalTo(snp.right)
        }
    }
    
    private func configureButtons() {
        addToCartButton.addTarget(self, action: #selector(addToCartButtonAction), for: .touchUpInside)
        removeButton.addTarget(self, action: #selector(removeButtonAction), for: .touchUpInside)
    }
    
    @objc private func addToCartButtonAction() {
        delegate?.didTappedAddButton(self)
    }
    
    @objc private func removeButtonAction() {
        delegate?.didTappedRemoveButton(self)
    }
    
    private func configureScrollView(photos: [String], size: CGSize) {
        addSubview(scrollView)
        scrollView.isPagingEnabled = false
        scrollView.showsHorizontalScrollIndicator = false
        
        StorageService.sharedInstance.getImagesFromUrls(images: photos, size: size) { [weak self] result in
            switch result {
            case .success(let imageView):
                self?.scrollView.addSubview(imageView)
            case .failure(let error):
                fatalError("\(error)")
            }
        }
        
        addSubview(removeButton)
        
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(snp.top)
            make.width.equalTo(snp.width)
            make.height.equalTo(170)
        }
        
        scrollView.contentSize = CGSize(width: CGFloat(photos.count) * frame.width,
                                        height: scrollView.frame.height)
    }
}

// MARK: - LikeState
extension FavoriteCell {
    enum LikeState {
        case none
        case liked
        case unliked
    }
}
