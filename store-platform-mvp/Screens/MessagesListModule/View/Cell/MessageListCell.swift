import UIKit

class MessageListCell: UICollectionViewCell {
    static let reuseId = "MessageList"
    
    let recipientNameLabel = UILabel(text: nil, font: nil, textColor: .black)
    let lastMessageLabel = UILabel(text: nil, font: nil, textColor: .black)
    let timeLabel = UILabel(text: nil, font: nil, textColor: .systemGray)
    let dateLabel = UILabel(text: nil, font: nil, textColor: .systemGray)
}

extension MessageListCell {
    func configure(messageListItem: Conversation) {
        self.recipientNameLabel.text = messageListItem.recipientName.capitalized
        self.lastMessageLabel.text = messageListItem.lastMessage
        
        configureTime(date: messageListItem.date)
        configureViews()
    }
    
    // FIXME: make a dateformatter static manager
    func configureTime(date: String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .medium
        dateFormatter.timeZone = .current
        dateFormatter.locale = Locale(identifier: "en_GB")
        
        guard let fetchedDate = dateFormatter.date(from: date) else {
            return
        }
        
        dateFormatter.dateFormat = "HH:mm"
        timeLabel.text = dateFormatter.string(from: fetchedDate)
        dateFormatter.dateFormat = "d MMM"
        dateFormatter.locale = .current
        dateLabel.text = "\(dateFormatter.string(from: fetchedDate)),"
    }
    
    func configureViews() {
        self.recipientNameLabel.font = Constants.Fonts.itemTitleFont
        self.lastMessageLabel.font = Constants.Fonts.itemDescriptionFont
        
        self.timeLabel.font = .systemFont(ofSize: 10, weight: .light)
        self.dateLabel.font = .systemFont(ofSize: 10, weight: .light)

        let symbolConfiguration = UIImage.SymbolConfiguration(scale: .medium)
        let arrowImageView = UIImageView(image: UIImage(systemName: "chevron.right",
                                                        withConfiguration: symbolConfiguration)?
            .withTintColor(.black, renderingMode: .alwaysOriginal))

        let stack = UIStackView(arrangedSubviews: [recipientNameLabel, lastMessageLabel], spacing: 5, axis: .vertical, alignment: .fill)
        
        addSubview(stack)
        stack.snp.makeConstraints { make in
            make.top.equalTo(snp.top)
            make.left.equalTo(snp.left)
        }
        
        lastMessageLabel.snp.makeConstraints { make in
            make.width.equalTo(200)
        }
        
        addSubview(arrowImageView)
        arrowImageView.snp.makeConstraints { make in
            make.right.equalTo(snp.right)
            make.centerY.equalTo(snp.centerY)
        }
        
        let dateTimeStack = UIStackView(arrangedSubviews: [dateLabel, timeLabel], spacing: 2, axis: .horizontal, alignment: .fill)
        addSubview(dateTimeStack)
        dateTimeStack.snp.makeConstraints { make in
            make.top.equalTo(snp.top)
            make.right.equalTo(snp.right)
        }
    }
}
