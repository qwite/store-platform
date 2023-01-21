import Foundation
import UIKit
import MessageKit

// MARK: - MessengerPresenterProtocol
protocol MessengerPresenterProtocol {
    init(view: MessengerViewProtocol,
         service: UserServiceProtocol,
         conversationId: String?,
         recipientBrandId: String?,
         isBrand: Bool,
         coordinator: MessagesCoordinatorProtocol)
    
    func viewDidAppear()
    func viewDidLoad()
    func finish()
    
    func getSelfSender() -> SenderType
    func getUserSender() -> SenderType
    func getBrandSender() -> SenderType
    
    //    func createConversation(with text: String)
    func listenMessages()
    func sendMessage(with text: String)
    func showImagePicker()
    func sendAttachment(image: Data)
    func didShowImageDetailed(imageUrl: URL)
    
    var conversationId: String? { get set }
    var messages: [Message]! { get set }    
}

// MARK: - MessengerPresenterProtocol Implementation
class MessengerPresenter: MessengerPresenterProtocol {
    weak var view: MessengerViewProtocol?
    weak var coordinator: MessagesCoordinatorProtocol?
    var service: UserServiceProtocol?
    
    var messages: [Message]! = nil
    
    var conversationId: String?
    var recipientBrandId: String?
    var isBrand: Bool
    var brandName: String?
    
    required init(view: MessengerViewProtocol,
                  service: UserServiceProtocol,
                  conversationId: String?,
                  recipientBrandId: String?,
                  isBrand: Bool = false,
                  coordinator: MessagesCoordinatorProtocol) {
        
        self.view = view
        self.service = service
        self.conversationId = conversationId
        self.coordinator = coordinator
        self.recipientBrandId = recipientBrandId
        self.isBrand = isBrand
    }
    
    func viewDidLoad() {
        view?.configure()
    }
    
    func viewDidAppear() {
        listenMessages()
    }
    
    func finish() {
        coordinator?.finishFlow?()
    }
    
    func getSelfSender() -> SenderType {
        self.isBrand ? getBrandSender() : getUserSender()
    }
    
    func getUserSender() -> SenderType {
        guard let userId = SettingsService.sharedInstance.userId,
              let fullName = SettingsService.sharedInstance.userFullName,
              let firstName = fullName["firstName"] else {
            fatalError("Unwrapping user error")
        }
        
        let userSender = Sender(senderId: userId, displayName: firstName)
        return userSender
    }
    
    func getBrandSender() -> SenderType {
        guard let brandId = recipientBrandId,
              let brandName = SettingsService.sharedInstance.brandName else {
            fatalError("Unwrapping brand error")
        }
        
        let brandSender = Sender(senderId: brandId, displayName: brandName)
        return brandSender
    }
    
    func getRecipientId() {}
    
    func showImagePicker() {
        coordinator?.showImagePicker()
    }
    
    func didShowImageDetailed(imageUrl: URL) {
        StorageService.sharedInstance.getImageFromUrl(imageUrl: imageUrl.absoluteString) { [weak self] result in
            switch result {
            case .success(let data):
                self?.coordinator?.showDetailedImage(data: data)
            case .failure(_):
                fatalError("error with downloading data")
            }
        }
    }
    
    // create conversation with brand
    func createConversation(message: Message) {
        guard let brandId = self.recipientBrandId else {
            debugPrint("Unwrapping recipient brandId Error"); return
        }
        
        FirestoreService.sharedInstance.getBrandName(brandId: brandId) { [weak self] result in
            switch result {
            case .success(let brandName):
                RealTimeService.sharedInstance.createNewConversation(with: brandId, brandName: brandName, firstMessage: message) { result in
                    switch result {
                    case .success(let conversationId):
                        debugPrint("[Log] Conversation created")
                        self?.conversationId = conversationId
                        self?.listenMessages()
                    case .failure(let error):
                        fatalError("\(error)")
                    }
                }
            case .failure(let error):
                fatalError("\(error)")
            }
        }
    }
    
    // Observing messages
    func listenMessages() {
        self.view?.loadFirstMessages()
        
        // checks if conversation already created; if not return
        guard let conversationId = conversationId else {
            self.view?.stopLoadingMessages(); return
        }
        
        // fetch all messages with brand
        RealTimeService.sharedInstance.getAllMessagesForConversation(with: conversationId) { [weak self] result in
            switch result {
            case .success(let messages):
                self?.messages = messages
                self?.view?.stopLoadingMessages()
            case .failure(let error):
                fatalError("\(error)")
            }
        }
    }
    
    func sendMessage(with text: String) {
        let sender = getSelfSender()
        let message = Message(sender: sender, sentDate: Date(), kind: .text(text))
        
        guard let conversationId = self.conversationId else {
            createConversation(message: message); return
        }
        
        RealTimeService.sharedInstance.sendMessage(to: conversationId, newMessage: message, role: .user) { error in
            guard error == nil else {
                fatalError("\(error!)")
            }
            
            print("[Log] Message sent with text: \(text)")
        }
    }
    
    func sendAttachment(image: Data) {
        StorageService.sharedInstance.uploadImage(with: image, type: .messageAttachment) { [weak self] result in
            switch result {
            case .success(let imageUrl):
                guard let url = URL(string: imageUrl),
                      let placeholder = UIImage(systemName: "plus"),
                      let sender = self?.getSelfSender() else {
                    fatalError()
                }
                
                let media = Media(url: url, image: nil, placeholderImage: placeholder, size: .zero)
                let message = Message(sender: sender, sentDate: Date(), kind: .photo(media))
                
                guard let conversationId = self?.conversationId else {
                    self?.createConversation(message: message); return
                }

                RealTimeService.sharedInstance.sendMessage(to: conversationId, newMessage: message, role: .brand) { error in
                    guard error == nil else {
                        fatalError()
                    }
                    
                    print("[Log] Attachment sended")
                }
                
                print(imageUrl)
            case .failure(let error):
                fatalError("\(error)")
            }
        }
    }
}

// TODO: Add loading progressbar
// MARK: - ImagePickerDelegate
extension MessengerPresenter: ImagePickerDelegate {
    func didImageAdded(image: Data) {
        self.sendAttachment(image: image)
    }
}
