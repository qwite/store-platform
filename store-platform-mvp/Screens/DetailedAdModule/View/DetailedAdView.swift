import UIKit

protocol DetailedAdViewDelegate: AnyObject {
    func didTappedSelectSizeButton()
    func didTappedAddCartButton()
}

class DetailedAdView: UIView {
    weak var delegate: DetailedAdViewDelegate?
    
    let brandLabel = UILabel(text: "",
                             font: .systemFont(ofSize: 18, weight: .semibold),
                             textColor: .black)
    
    let itemLabel = UILabel(text: "",
                            font: .systemFont(ofSize: 15, weight: .regular),
                            textColor: .black)
    let priceLabel = UILabel(text: "",
                             font: .systemFont(ofSize: 15, weight: .regular),
                             textColor: .black)
    
    let starIcon = UIImageView(image: UIImage(systemName: "star.fill")?
                                .withTintColor(.black, renderingMode: .alwaysOriginal))
    
    let ratingLabel = UILabel(text: "0.0",
                              font: .systemFont(ofSize: 14, weight: .regular),
                              textColor: .black)
    
    let quantityReview = UILabel(text: "Отзывы: нет",
                                 font: .systemFont(ofSize: 14, weight: .regular),
                                 textColor: .black)
    
    let sizeHeaderLabel = UILabel(text: "Выберите размер: ",
                                  font: .systemFont(ofSize: 18, weight: .medium),
                                  textColor: .black)
    
    let selectSizeButton = UIButton(text: "Выберите размер", preset: .select)
    let descriptionHeaderLabel = UILabel(text: "Описание",
                                         font: .systemFont(ofSize: 18, weight: .medium),
                                         textColor: .black)
    
    let descriptionLabel = UILabel(text: "",
                                   font: UIFont.systemFont(ofSize: 14, weight: .regular),
                                   textColor: .black)
    
    let photoScrollView = UIScrollView()
    let pageControl = UIPageControl()
    let photoSize: CGSize = CGSize(width: UIScreen.main.bounds.width, height: 350)
    let scrollView = UIScrollView(frame: .zero)
    let addCartButton = UIButton(text: "Добавить в корзину", preset: .bottom)
}

extension DetailedAdView {
    func configure(with item: Item) {
        guard let photos = item.photos,
              let sizes = item.sizes,
              let firstPrice = sizes.first?.price else {
            fatalError("error with item object")
        }
        
        brandLabel.text = item.brandName
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
    }
    
    func configureViews() {
        backgroundColor = .white
        descriptionLabel.numberOfLines = 0
        pageControl.hidesForSinglePage = true
        pageControl.currentPageIndicatorTintColor = .black
        pageControl.pageIndicatorTintColor = .gray

        
        let itemStack = UIStackView(arrangedSubviews: [pageControl, brandLabel, itemLabel, priceLabel], spacing: 3, axis: .vertical, alignment: .center)
        
        let descriptionStack = UIStackView(arrangedSubviews: [descriptionHeaderLabel, descriptionLabel], spacing: 15, axis: .vertical, alignment: .fill)
        
        addSubview(scrollView)
        
        scrollView.snp.makeConstraints { make in
//            make.height.equalTo(snp.height)
            make.top.equalTo(snp.top)
            make.left.equalTo(snp.left)
            make.right.equalTo(snp.right)
            make.bottom.equalTo(snp.bottom)
        }
        

        let contentStack = UIStackView(arrangedSubviews: [itemStack, selectSizeButton, descriptionStack],
                                       spacing: 30,
                                       axis: .vertical,
                                       alignment: .leading)
        
        scrollView.addSubview(photoScrollView)
        scrollView.addSubview(contentStack)
        
        photoScrollView.snp.makeConstraints { make in
            make.top.equalTo(scrollView.snp.top)
            make.width.equalTo(snp.width)
            make.height.equalTo(photoSize.height)
        }

        photoScrollView.isPagingEnabled = true
        photoScrollView.showsHorizontalScrollIndicator = false
        
        itemStack.snp.makeConstraints { make in
            make.top.equalTo(photoScrollView.snp.bottom).offset(5)
            make.centerX.equalTo(scrollView.snp.centerX)
        }
        
        contentStack.snp.makeConstraints { make in
            make.left.equalTo(scrollView.snp.left).offset(20)
            make.right.equalTo(scrollView.snp.right)
            make.bottom.equalTo(scrollView.snp.bottom)
        }
        
        addSubview(addCartButton)
        addCartButton.snp.makeConstraints { make in
          make.bottom.equalTo(self.safeAreaLayoutGuide.snp.bottom).offset(-55)
          make.centerX.equalTo(self.snp.centerX)
          make.height.equalTo(34)
          make.width.equalTo(self.snp.width).dividedBy(2)
        }
        
    }
    
    func configureButtons() {
        addCartButton.addTarget(self, action: #selector(addCartButtonAction), for: .touchUpInside)
        selectSizeButton.addTarget(self, action: #selector(selectSizeButtonAction), for: .touchUpInside)
    }
    
    @objc func addCartButtonAction() {
        delegate?.didTappedAddCartButton()
    }
    
    @objc func selectSizeButtonAction() {
        delegate?.didTappedSelectSizeButton()
    }
}
