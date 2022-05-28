import UIKit

protocol AdCellDelegate: AnyObject {
    func didTappedLikeButton(_ adCell: AdCell)
    func didUntappedLikeButton(_ adCell: AdCell)
}

class AdCell: UICollectionViewCell {
    static let reuseId: String = "AdCell"
    weak var delegate: AdCellDelegate?
    lazy var scrollView = UIScrollView()
    lazy var brandNameLabel = UILabel(text: "", font: UIFont.systemFont(ofSize: 18, weight: .semibold), textColor: .black)
    lazy var clothingNameLabel = UILabel(text: "", font: UIFont.systemFont(ofSize: 15, weight: .regular), textColor: .black)
    lazy var priceLabel = UILabel(text: "", font: UIFont.systemFont(ofSize: 15, weight: .regular), textColor: .black)
    lazy var heartButton = UIButton(text: nil, preset: .icon, iconName: "heart", selectedIconName: "heart.fill")
    var likeState: LikeState?
}

// MARK: - Helpers func
extension AdCell {
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
        configureButtons()
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
        scrollView.layer.borderWidth = 1.0
        scrollView.layer.cornerRadius = 20
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
//        heartButton.backgroundColor = .red
        
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
    
    func configureButtons() {
        heartButton.addTarget(self, action: #selector(likeButtonTapped), for: .touchUpInside)
    }
    
    @objc func likeButtonTapped() {
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

extension AdCell {
    enum LikeState {
        case none
        case liked
        case unliked
    }
}
