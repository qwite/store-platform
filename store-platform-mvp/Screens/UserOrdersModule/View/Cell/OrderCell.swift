import UIKit
import SPAlert

class OrderCell: UICollectionViewCell {
    static let reuseId = "Order"
    let imageView = UIImageView()
    let orderNumberLabel = UILabel(text: nil, font: nil, textColor: .systemBlue)
    let dateOrderLabel = UILabel(text: nil, font: nil, textColor: .black)
    let brandNameLabel = UILabel(text: nil, font: nil, textColor: .black)
    let clothingNameLabel = UILabel(text: nil, font: nil, textColor: .black)
    let priceLabel = UILabel(text: nil, font: nil, textColor: .black)
    let statusLabel = UILabel(text: nil, font: nil, textColor: .black)
}

extension OrderCell {
    public func configure(order: Order) {
        guard let firstPhotoUrl = order.item.item.photos?.first else { return }
        
        orderNumberLabel.text = "\(order.id ?? "null") "
        dateOrderLabel.text = "Заказ от \(order.date)"
    
        configureStatusLabel(status: order.status)
        configureDateLabel(date: order.date)
        configureImageView(photo: firstPhotoUrl)
        configureViews()
        
    }
}

extension OrderCell {
    private func configureViews() {
        imageView.contentMode = .scaleAspectFit
        dateOrderLabel.font = .systemFont(ofSize: 16, weight: .regular)
        
        orderNumberLabel.font = .systemFont(ofSize: 16, weight: .regular)
        orderNumberLabel.isUserInteractionEnabled = true
        orderNumberLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(copyOrderNumberText(sender:))))
        statusLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        
        let infoStack = UIStackView(arrangedSubviews: [dateOrderLabel, orderNumberLabel, statusLabel], spacing: 5, axis: .vertical, alignment: .fill)
        
        addSubview(infoStack)
        infoStack.snp.makeConstraints { make in
            make.top.equalTo(snp.top)
        }
        
        addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.left.equalTo(snp.left)
            make.width.equalTo(50)
            make.height.equalTo(50)
            make.centerY.equalTo(infoStack.snp.centerY)
        }
        
        infoStack.snp.makeConstraints { make in
            make.left.equalTo(imageView.snp.right).offset(20)
        }
    }
    
    private func configureStatusLabel(status: Order.Status.RawValue) {
        var resultText: String = ""
        
        switch status {
        case "process":
            resultText = "В обработке"
        case "shipped":
            resultText = "Отправлен"
        case "delivered":
            resultText = "Доставлен"
        default:
            break
        }
        
        statusLabel.text = resultText
    }
    
    private func configureImageView(photo: String) {
        let photoSize = CGSize(width: 50, height: frame.size.height)
        StorageService.sharedInstance.getImagesFromUrls(images: [photo], size: photoSize) { result in
            guard let imageView = try? result.get() else {
                return
            }
            
            debugPrint(self.frame.size.height)
            self.imageView.image = imageView.image
        }
    }
    
    // FIXME: make a dateformatter static manager
    private func configureDateLabel(date: String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .medium
        dateFormatter.timeZone = .current
        dateFormatter.locale = Locale(identifier: "en_GB")
        
        guard let fetchedDate = dateFormatter.date(from: date) else {
            return
        }
        
        dateFormatter.dateFormat = "d MMM"
        dateFormatter.locale = .current
        dateOrderLabel.text = "Заказ от \(dateFormatter.string(from: fetchedDate))"
    }
    
    @objc private func copyOrderNumberText(sender: UITapGestureRecognizer) {
        guard let text = orderNumberLabel.text else { return }
        UIPasteboard.general.string = text
        SPAlert.present(message: "Номер заказа скопирован", haptic: .success)
    }
}
