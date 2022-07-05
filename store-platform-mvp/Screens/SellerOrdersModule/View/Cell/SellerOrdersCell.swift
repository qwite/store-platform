import UIKit

class SellerOrdersCell: UICollectionViewCell {
    static let reuseId = "SellerOrders"
    let imageView = UIImageView(image: UIImage(named: "clo_test"))
    let orderNumberLabel = UILabel(text: nil, font: nil, textColor: .systemGray)
    let dateLabel = UILabel(text: nil, font: nil, textColor: .systemGray)
    let statusLabel = UILabel(text: nil, font: nil, textColor: .systemGray)
    let selectedSizeLabel = UILabel(text: nil, font: nil, textColor: .black)
    let paidPriceLabel = UILabel(text: nil, font: nil, textColor: .black)
    let shippingAddressLabel = UILabel(text: nil, font: nil, textColor: .black)
    let userPhoneNumberLabel = UILabel(text: nil, font: nil, textColor: .black)
    let userFullNameLabel = UILabel(text: nil, font: nil, textColor: .black)
}

extension SellerOrdersCell {
    func configure(order: Order) {
        guard let number = order.id,
              let firstPhotoUrl = order.item.item.photos?.first else { return }
        
        orderNumberLabel.text = "Номер заказа: \(number)"
        dateLabel.text = order.date
        selectedSizeLabel.text = "Выбранный размер: \(order.item.selectedSize)"
        paidPriceLabel.text = "Оплачено: \(order.item.selectedPrice) ₽"
        shippingAddressLabel.text = "Адрес доставки: \n\(order.userShippingAddress)"
        userPhoneNumberLabel.text = "Контактный номер клиента: \(order.userPhoneNumber)"
        userFullNameLabel.text = "ФИО клиента: \(order.userFullName)"
        
        
        configureViews()
        configureStatusLabel(status: order.status)
        configureImageView(photo: firstPhotoUrl)
    }
}

extension SellerOrdersCell {
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
    
    private func configureViews() {
        imageView.contentMode = .scaleAspectFit
        shippingAddressLabel.numberOfLines = 0
        
        orderNumberLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        dateLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        statusLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        
        selectedSizeLabel.font = .systemFont(ofSize: 16, weight: .regular)
        paidPriceLabel.font = .systemFont(ofSize: 16, weight: .regular)
        shippingAddressLabel.font = .systemFont(ofSize: 16, weight: .regular)
        userPhoneNumberLabel.font = .systemFont(ofSize: 16, weight: .regular)
        userFullNameLabel.font = .systemFont(ofSize: 16, weight: .regular)
        
        let orderStack = UIStackView(arrangedSubviews: [orderNumberLabel, dateLabel, statusLabel], spacing: 5, axis: .vertical, alignment: .fill)
        
        let orderStackFinal = UIStackView(arrangedSubviews: [imageView, orderStack], spacing: 10, axis: .horizontal, alignment: .fill)
        
        addSubview(orderStackFinal)
        orderStackFinal.snp.makeConstraints { make in
            make.top.equalTo(snp.top)
            make.left.equalTo(snp.left)
        }
        
        imageView.snp.makeConstraints { make in
            make.height.equalTo(60)
            make.width.equalTo(50)
        }
        
        
        let childStack = UIStackView(arrangedSubviews: [selectedSizeLabel, paidPriceLabel, shippingAddressLabel, userPhoneNumberLabel, userFullNameLabel], spacing: 5, axis: .vertical, alignment: .fill)
        
        
        
        addSubview(childStack)
        childStack.snp.makeConstraints { make in
            make.top.equalTo(orderStackFinal.snp.bottom).offset(20)
            make.left.equalTo(snp.left)
            make.width.equalTo(snp.width)
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
        
        statusLabel.text = "Текущий статус: \(resultText)"
    }
}
