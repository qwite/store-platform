import UIKit
import MessageKit
import InputBarAccessoryView
import Kingfisher

// MARK: - MessengerViewProtocol
protocol MessengerViewProtocol: AnyObject {
    func loadFirstMessages()
    func stopLoadingMessages()
}

// MARK: - MessengerViewController
class MessengerViewController: MessagesViewController {
    public var presenter: MessengerPresenterProtocol!
    
    // MARK: Lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.viewDidAppear()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewDidLoad()
        
        view.backgroundColor = .white
        title = "Мессенджер"
        navigationItem.largeTitleDisplayMode = .never
        
        configureMessenger()
    }
}

extension MessengerViewController: MessengerViewProtocol {
    func loadFirstMessages() {
        messagesCollectionView.refreshControl?.beginRefreshing()
    }
    
    func stopLoadingMessages() {
        messagesCollectionView.reloadData()
        self.messagesCollectionView.refreshControl?.endRefreshing()
        self.messagesCollectionView.scrollToLastItem(at: .bottom, animated: true)
    }
}

extension MessengerViewController: MessagesDisplayDelegate {
    func configureMessenger() {
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messageCellDelegate = self
        messageInputBar.delegate = self
        
        configureInputButtons()
        configureAvatars()
        configureRefreshControl()
    }
    
    func configureRefreshControl() {
        let attributedFont = Constants.Fonts.itemDescriptionFont
        let refreshAttributedTitle: NSAttributedString = .init(string: "Обновление данных", attributes: [NSAttributedString.Key.font: attributedFont])
        messagesCollectionView.refreshControl = UIRefreshControl()
        guard let refreshControl = messagesCollectionView.refreshControl else {
            return
        }
        
        refreshControl.attributedTitle = refreshAttributedTitle
        refreshControl.addTarget(self, action: #selector(handleRefreshControl), for: .valueChanged)
    }
    
    func configureAvatars() {
        messagesCollectionView.messagesCollectionViewFlowLayout.setMessageIncomingAvatarSize(.zero)
        messagesCollectionView.messagesCollectionViewFlowLayout.setMessageOutgoingAvatarSize(.zero)
        
        messagesCollectionView.messagesCollectionViewFlowLayout.setMessageIncomingMessageTopLabelAlignment(
            .init(textAlignment: .left, textInsets: .init(top: 0, left: 10, bottom: 0, right: 0)))
        messagesCollectionView.messagesCollectionViewFlowLayout.setMessageOutgoingMessageTopLabelAlignment(
            .init(textAlignment: .right, textInsets: .init(top: 0, left: 0, bottom: 0, right: 10)))
        
        messagesCollectionView.messagesCollectionViewFlowLayout.setMessageIncomingMessageBottomLabelAlignment(.init(textAlignment: .left, textInsets: .init(top: 0, left: 10, bottom: 0, right: 0)))
        messagesCollectionView.messagesCollectionViewFlowLayout.setMessageOutgoingMessageBottomLabelAlignment(.init(textAlignment: .right, textInsets: .init(top: 0, left: 0, bottom: 0, right: 10)))
        
    }
    
    @objc private func handleRefreshControl() {
        self.messagesCollectionView.refreshControl?.endRefreshing()
    }
    
    func configureInputButtons() {
        messageInputBar.sendButton.configure { button in
            let buttonFont: UIFont = .systemFont(ofSize: 14, weight: .bold)
            let attributedString = NSAttributedString(string: "Отправить", attributes: [NSAttributedString.Key.font: buttonFont,
                                                                                        NSAttributedString.Key.foregroundColor: UIColor.black])
            button.setAttributedTitle(attributedString, for: .normal)
        }
        
        messageInputBar.setRightStackViewWidthConstant(to: 100, animated: false)

        let button = InputBarButtonItem()
        button.setSize(CGSize(width: 35, height: 35), animated: false)
        button.setImage(UIImage(systemName: "paperclip")?.withTintColor(.black, renderingMode: .alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(attachmentButtonAction), for: .touchUpInside)
        
        messageInputBar.setLeftStackViewWidthConstant(to: 35, animated: false)
        messageInputBar.setStackViewItems([button], forStack: .left, animated: false)
    }
    
    @objc private func attachmentButtonAction() {
        presenter.didShowImagePicker()
    }
    
    func currentSender() -> SenderType {
        return presenter.getSelfSender()
    }

    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        guard let messages = presenter.messages else {
            return Message(sender: presenter.getSelfSender(), sentDate: Date(), kind: .text(""), messageId: "error")
        }
        
        return messages[indexPath.section]
    }

    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        guard let messages = presenter.messages else {
            return 0
        }
        
        return messages.count
    }
}
// MARK: - MessagesLayoutDelegate
extension MessengerViewController: MessagesLayoutDelegate {
    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 20
    }
    
    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 20
    }
}

// MARK: - MessagesDataSource
extension MessengerViewController: MessagesDataSource {
    func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let name = message.sender.displayName
        let senderNameFont: UIFont = .systemFont(ofSize: 14, weight: .semibold)
        let recipientNameFont: UIFont = .systemFont(ofSize: 14, weight: .regular)
        
        let attributedStringSender = NSAttributedString(string: name, attributes: [
            NSAttributedString.Key.font: senderNameFont
        ])
        
        let attributedStringRecipient = NSAttributedString(string: name, attributes: [
            NSAttributedString.Key.font: recipientNameFont
        ])
        
        return isFromCurrentSender(message: message) ? attributedStringSender : attributedStringRecipient
    }
    
    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let dateString = presenter.convertFromDate(date: message.sentDate)
        let dateStringFont: UIFont = .systemFont(ofSize: 10, weight: .light)
        let attributedString = NSAttributedString(string: dateString, attributes: [NSAttributedString.Key.font: dateStringFont])
        return attributedString
    }
    
    func configureMediaMessageImageView(_ imageView: UIImageView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        switch message.kind {
        case .photo(let media):
            guard let imageUrl = media.url else {
                return
            }
            
            imageView.kf.setImage(with: imageUrl, options: [.cacheOriginalImage])
            imageView.contentMode = .scaleAspectFit
            imageView.backgroundColor = .white
        default:
            break
        }
    }
    
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        return .custom { messageContainerView in
            messageContainerView.style = .bubbleOutline(.black)
            messageContainerView.backgroundColor = .white
            
        }
    }
    
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        switch message.kind {
        case .text(_):
            return isFromCurrentSender(message: message) ? .black : .black
        default:
            return isFromCurrentSender(message: message) ? .black : .black
        }
    }
}

// MARK: - MessageCellDelegate
extension MessengerViewController: MessageCellDelegate {
    func didTapImage(in cell: MessageCollectionViewCell) {
        guard let indexPath = messagesCollectionView.indexPath(for: cell) else {
            return
        }
        
        let message = self.messageForItem(at: indexPath, in: messagesCollectionView)
        switch message.kind {
        case .photo(let media):
            if let url = media.url {
                presenter.didShowImageDetailed(imageUrl: url)
            }
        default:
            break
        }
        
    }
}
// MARK: - InputBarAccessoryViewDelegate
extension MessengerViewController: InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        presenter.sendMessage(with: text)
        
        inputBar.inputTextView.text = ""
    }
}
