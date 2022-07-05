import UIKit

// MARK: - AdCellDelegate Protocol
protocol AdCellDelegate: AnyObject {
    func didTappedLikeButton(_ adCell: AdCell)
    func didUntappedLikeButton(_ adCell: AdCell)
}

//MARK: - UICollectionViewCell
class AdCell: UICollectionViewCell {
    static let reuseId: String = "AdCell"
    weak var delegate: AdCellDelegate?
    
    lazy var scrollView = UIScrollView()
    lazy var brandNameLabel = UILabel(text: "", font: UIFont.systemFont(ofSize: 18, weight: .semibold), textColor: .black)
    lazy var clothingNameLabel = UILabel(text: "", font: UIFont.systemFont(ofSize: 15, weight: .regular), textColor: .black)
    lazy var priceLabel = UILabel(text: "", font: UIFont.systemFont(ofSize: 15, weight: .regular), textColor: .black)
    lazy var heartButton = UIButton(text: nil, preset: .icon, iconName: "heart", selectedIconName: "heart.fill")
    var likeState: LikeState?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.brandNameLabel.text = nil
        self.clothingNameLabel.text = nil
        self.priceLabel.text = nil
        self.scrollView.subviews.forEach({ $0.removeFromSuperview() })
    }
}

// MARK: - Public functions
extension AdCell {
    public func configure(with item: Item) {
        self.brandNameLabel.text = item.brandName.capitalized
        self.clothingNameLabel.text = item.clothingName
        
        // Show first price from available sizes
        if let firstPrice = item.sizes?.first?.price {
            self.priceLabel.text = "\(firstPrice) ₽"
        }

        if let photos = item.photos {
            configureScrollView(photos: photos, size: CGSize(width: frame.width, height: 170))
        }
        
        configureViews()
        configureButtons()
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
        
        addSubview(heartButton)
        
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(snp.top)
            make.width.equalTo(snp.width)
            make.height.equalTo(170)
        }
        
        heartButton.snp.makeConstraints { make in
            make.top.equalTo(snp.top)
            make.right.equalTo(snp.right)
        }
        
        scrollView.contentSize = CGSize(width: CGFloat(photos.count) * frame.width,
                                        height: scrollView.frame.height)
    }
    
    private func configureButtons() {
        heartButton.addTarget(self, action: #selector(likeButtonTapped), for: .touchUpInside)
    }
    
    @objc private func likeButtonTapped() {
        if heartButton.isSelected {
            heartButton.isSelected = false
            likeState = .unliked
            delegate?.didUntappedLikeButton(self)
        } else {
            heartButton.isSelected = true
            likeState = .liked
            delegate?.didTappedLikeButton(self)
        }
    }
}

// MARK: - LikeState
extension AdCell {
    enum LikeState {
        case none
        case liked
        case unliked
    }
}
