import UIKit

// MARK: - TotalCartViewDelegate
protocol TotalCartViewDelegate: AnyObject {
    func updateTotalPrice(price: Int)
}

// MARK: - TotalCartView
class TotalCartView: UICollectionReusableView {
    // MARK: Properies
    static let reuseId = "TotalCart"
    weak var delegate: CartViewDelegate?
    let separator = UIView()
    let totalPriceDescriptionLabel = UILabel(text: nil, font: nil, textColor: .black)
    let totalPriceLabel = UILabel(text: nil, font: nil, textColor: .black)
    let totalButton = UIButton(text: "Перейти к оформлению", preset: .bottom)
}

// MARK: - Public methods
extension TotalCartView {
    public func configure() {
        configureViews()
        configureButtons()
    }
}

// MARK: - Private methods
extension TotalCartView {
    private func configureViews() {
        totalPriceDescriptionLabel.text = "Общая стоимость"
        totalPriceLabel.font = Constants.Fonts.itemTitleFont
        totalPriceDescriptionLabel.font = Constants.Fonts.itemTitleFont
        
        addSubview(separator)
        
        separator.layer.borderColor = UIColor.lightGray.cgColor
        separator.layer.borderWidth = 1.0
        
        separator.snp.makeConstraints { make in
            make.width.equalTo(snp.width)
            make.height.equalTo(0.5)
            make.top.equalTo(snp.top).offset(10)
        }
        
        let labelsStack = UIStackView(arrangedSubviews: [totalPriceDescriptionLabel, totalPriceLabel], spacing: 10, axis: .horizontal, alignment: .fill)
        
//        labelsStack.distribution = .fill
        addSubview(labelsStack)
        
        labelsStack.snp.makeConstraints { make in
            make.top.equalTo(separator.snp.bottom).offset(20)
            make.left.equalTo(snp.left)
            make.right.equalTo(snp.right)
        }
        
        addSubview(totalButton)
        totalButton.snp.makeConstraints { make in
            make.bottom.equalTo(snp.bottom)
            make.width.equalTo(196)
            make.height.equalTo(34)
            make.centerX.equalTo(snp.centerX)
        }
    }
    
    private func configureButtons() {
        totalButton.addTarget(self, action: #selector(totalButtonAction), for: .touchUpInside)
    }
    
    @objc func totalButtonAction() {
        delegate?.didTappedTotalButton()
    }
}

// MARK: - TotalCartViewDelegate
extension TotalCartView: TotalCartViewDelegate {
    func updateTotalPrice(price: Int) {
        self.totalPriceLabel.text = "\(price) ₽"
    }
}
