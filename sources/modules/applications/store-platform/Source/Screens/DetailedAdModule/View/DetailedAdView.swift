import UIKit

// MARK: - DetailedAdViewDelegate
protocol DetailedAdViewDelegate: AnyObject {
    func didTappedSelectSizeButton()
    func didTappedAddCartButton()
    func didTappedCommunicationButton()
    func didTappedSubscriptionButton()
}

// MARK: - DetailedAdView
class DetailedAdView: UIView {
    weak var delegate: DetailedAdViewDelegate?
    
    // MARK: Properties
    var itemdId: String?
    
    let brandLabel = UILabel()
    let itemLabel = UILabel()
    let priceLabel = UILabel()
    let ratingLabel = UILabel()
    let quantityReview = UILabel()
    let sizeHeaderLabel = UILabel()
    let descriptionHeaderLabel = UILabel()
    let descriptionLabel = UILabel()
    
    let selectSizeButton = UIButton(text: "Выберите размер", preset: .select, symbol: true)
    let reviewsButton = UIButton(text: "Отзывы", preset: .select)
    let communicationButton = UIButton(text: "Связаться с продавцом", preset: .select)
    let subscriptionButton = UIButton(text: "Добавить в подписки", preset: .select)
    let addCartButton = UIButton(text: "Добавить в корзину", preset: .bottom)

    let photoScrollView = UIScrollView()
    let pageControl = UIPageControl()
    let photoSize: CGSize = CGSize(width: UIScreen.main.bounds.width, height: 350)
    let scrollView = UIScrollView(frame: .zero)
    let reviewStack = UIStackView()
}

// MARK: - Public methods
extension DetailedAdView {
    func configure(with item: Item) {
        addCartButton.isHidden = true
        
        guard let photos = item.photos,
              let firstSize = item.sizes.first else {
            fatalError("error with item")
        }
        
        let firstPrice = firstSize.price
        
        brandLabel.text = item.brandName.capitalized
        itemLabel.text = item.clothingName
        descriptionLabel.text = item.description
        priceLabel.text = "\(firstPrice) ₽"
        
        StorageService.sharedInstance.getImagesFromUrls(images: photos, size: photoSize) { [weak self] result in
            switch result {
            case .success(let imageView):
                self?.photoScrollView.addSubview(imageView)
            case .failure(let error):
                debugPrint(error)
            }
        }
        
        photoScrollView.contentSize = CGSize(width: CGFloat(photos.count) * UIScreen.main.bounds.width,
                                             height: photoSize.height)
        pageControl.numberOfPages = photos.count
        
        configureViews()
        configureButtons()
    }
    
    public func createReviewStack(reviews: [Review]?) {
        guard let reviews = reviews else {
            reviewStack.removeFromSuperview(); return
        }

        for review in reviews {
            let userLabel = UILabel(text: review.userFirstName, font: .systemFont(ofSize: 15, weight: .semibold), textColor: .black)
            
            let cosmosView = configureStars(rating: review.rating)
            let userReviewLabel = UILabel(text: review.text, font: .systemFont(ofSize: 15, weight: .regular), textColor: .black)
            userReviewLabel.numberOfLines = 0
            let userReviewStack = UIStackView(arrangedSubviews: [userLabel, cosmosView, userReviewLabel], spacing: 5, axis: .vertical, alignment: .leading)
            
            reviewStack.addArrangedSubview(userReviewStack)
        }
    }
}

// MARK: - Private methods
extension DetailedAdView {
    private func configureViews() {
        configureLabels()
        
        backgroundColor = .white
        descriptionLabel.numberOfLines = 0
        descriptionLabel.lineBreakMode = .byWordWrapping
        pageControl.hidesForSinglePage = true
        pageControl.currentPageIndicatorTintColor = .black
        pageControl.pageIndicatorTintColor = .gray

        reviewStack.addArrangedSubview(reviewsButton)
        reviewStack.spacing = 15
        reviewStack.axis = .vertical
        reviewStack.alignment = .fill

        let itemStack = UIStackView(arrangedSubviews: [pageControl, brandLabel, itemLabel, priceLabel], spacing: 3, axis: .vertical, alignment: .center)
        
        let descriptionStack = UIStackView(arrangedSubviews: [descriptionHeaderLabel, descriptionLabel], spacing: 15, axis: .vertical, alignment: .fill)
        
        addSubview(scrollView)
                
        let contentStack = UIStackView(arrangedSubviews: [itemStack, selectSizeButton, descriptionStack, reviewStack, communicationButton, subscriptionButton],
                                       spacing: 10,
                                       axis: .vertical,
                                       alignment: .fill)
        
        scrollView.addSubview(photoScrollView)

        photoScrollView.isPagingEnabled = true
        photoScrollView.showsHorizontalScrollIndicator = false
        
        photoScrollView.snp.updateConstraints { make in
            make.top.equalTo(scrollView.snp.top)
            make.width.equalTo(snp.width)
            make.height.equalTo(photoSize.height)
        }
        
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(snp.edges)
        }
        
        scrollView.addSubview(contentStack)
                
        contentStack.snp.makeConstraints { make in
            make.top.equalTo(photoScrollView.snp.bottom).offset(10)
            make.left.equalTo(snp.left).offset(20)
            make.right.equalTo(snp.right).offset(-20)
            make.bottom.equalTo(scrollView.snp.bottom).offset(-100)
        }
        
        addSubview(addCartButton)
        addCartButton.snp.makeConstraints { make in
          make.bottom.equalTo(self.safeAreaLayoutGuide.snp.bottom).offset(-55)
          make.centerX.equalTo(self.snp.centerX)
          make.height.equalTo(34)
          make.width.equalTo(self.snp.width).dividedBy(2)
        }
    }
    
    private func configureLabels() {
        brandLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        itemLabel.font = .systemFont(ofSize: 15, weight: .regular)
        priceLabel.font = .systemFont(ofSize: 15, weight: .regular)
        ratingLabel.font = .systemFont(ofSize: 14, weight: .regular)
        quantityReview.font = .systemFont(ofSize: 14, weight: .regular)
        sizeHeaderLabel.font = .systemFont(ofSize: 18, weight: .medium)
        descriptionHeaderLabel.font = .systemFont(ofSize: 18, weight: .medium)
        descriptionLabel.font = .systemFont(ofSize: 14, weight: .regular)
        
        descriptionHeaderLabel.text = "Описание"
    }
        
    private func configureStars( rating: Double) -> UIView {
        // TODO("Create view with stars.")

        fatalError("Create view with stars.")
    }
        
    private func configureButtons() {
        addCartButton.addTarget(self, action: #selector(addCartButtonAction), for: .touchUpInside)
        selectSizeButton.addTarget(self, action: #selector(selectSizeButtonAction), for: .touchUpInside)
        communicationButton.addTarget(self, action: #selector(communicationButtonAction), for: .touchUpInside)
        subscriptionButton.addTarget(self, action: #selector(subscriptionButtonAction), for: .touchUpInside)
    }
    
    private func configureImageView(with urls: [String]) {
        
    }
    
    // MARK: Actions
    @objc private func addCartButtonAction() {
        delegate?.didTappedAddCartButton()
    }
    
    @objc private func selectSizeButtonAction() {
        delegate?.didTappedSelectSizeButton()
    }
    
    @objc private func communicationButtonAction() {
        delegate?.didTappedCommunicationButton()
    }
    
    @objc private func subscriptionButtonAction() {
        delegate?.didTappedSubscriptionButton()
    }
}
