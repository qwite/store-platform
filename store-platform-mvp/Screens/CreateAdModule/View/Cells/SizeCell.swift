import UIKit

// MARK: - Size Cell Delegate Protocol
protocol SizeCellDelegate {
    func didTappedAddSizeButton()
}

class SizeCell: UICollectionViewCell {
    static let reuseId: String = "ItemManagment"
    var delegate: SizeCellDelegate?
    
    lazy var sizeLabel = UILabel(text: nil,
                                 font: UIFont.systemFont(ofSize: 24, weight: .bold),
                                 textColor: .black)
    
    lazy var priceLabel = UILabel(text: nil,
                                  font: UIFont.systemFont(ofSize: 14, weight: .semibold),
                                  textColor: .black)
    
    lazy var amountLabel = UILabel(text: nil,
                                   font: UIFont.systemFont(ofSize: 14, weight: .regular),
                                   textColor: .systemGray)

    let iconImage: UIImageView = {
        let image = UIImageView(image: UIImage(systemName: "square.and.pencil")?.withTintColor(.black, renderingMode: .alwaysOriginal))
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    let plusImageView: UIImageView = {
        let image = UIImage(systemName: "plus.viewfinder")?.withTintColor(.lightGray, renderingMode: .alwaysOriginal)
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let plusButton: UIButton = {
        let button = UIButton(type: .custom)
        button.imageView?.contentMode = .scaleAspectFill
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureButtons()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension SizeCell {
    func configure(size: String?, price: Int?, amount: Int?) {
        guard let size = size,
              let price = price,
              let amount = amount else {
            return
        }

        layer.cornerRadius = 13
        layer.borderWidth = 1.0
        sizeLabel.text = "\(size)"
        priceLabel.text = "\(price) ₽"
        amountLabel.text = "\(amount) шт."
        
        let stack = UIStackView(arrangedSubviews: [sizeLabel, priceLabel, amountLabel])
        stack.spacing = 3
        stack.axis = .vertical
        stack.alignment = .leading
        stack.distribution = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(stack)
        addSubview(iconImage)
        
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            stack.leftAnchor.constraint(equalTo: leftAnchor, constant: 10),
            iconImage.topAnchor.constraint(equalTo: stack.topAnchor),
            iconImage.rightAnchor.constraint(equalTo: rightAnchor, constant: -5)
        ])
    }
    
    func makePlaceholder() {
        addSubview(plusButton)
        plusButton.addSubview(plusImageView)
        NSLayoutConstraint.activate([
            plusButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            plusButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            plusButton.widthAnchor.constraint(equalTo: widthAnchor),
            plusButton.heightAnchor.constraint(equalTo: heightAnchor),
            plusImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            plusImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            plusImageView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 1/2),
            plusImageView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 1/2),
        ])
    }
    
    func configureButtons() {
        plusButton.addTarget(self, action: #selector(plusButtonPressed), for: .touchUpInside)
    }
    
    @objc func plusButtonPressed() {
        delegate?.didTappedAddSizeButton()
    }
}
