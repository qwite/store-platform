import Foundation
import MessageKit

protocol MessengerPresenterProtocol: ImagePickerPresenterDelegate {
    init(view: MessengerViewProtocol, service: UserServiceProtocol, conversationId: String?, brandId: String?, coordinator: MessagesCoordinatorProtocol)
    func viewDidAppear()
    func viewDidLoad()
    
    func getSelfSender() -> SenderType
    
    //    func createConversation(with text: String)
    func listenMessages()
    func sendMessage(with text: String)
    func didShowImagePicker()
    func sendAttachment(image: Data)
    func didShowImageDetailed(imageUrl: URL)
    
    var conversationId: String? { get set }
    var messages: [Message]! { get set }
    
    func convertFromDate(date: Date) -> String
}

class MessengerPresenter: MessengerPresenterProtocol {
    weak var view: MessengerViewProtocol?
    weak var coordinator: MessagesCoordinatorProtocol?
    var service: UserServiceProtocol?
    var messages: [Message]! = nil
    
    var conversationId: String?
    var brandId: String?
    var brandName: String?
    
    // TODO: make dateformatter using for injection
    private let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .medium
        dateFormatter.timeZone = .current
        dateFormatter.locale = Locale(identifier: "en_GB")
        return dateFormatter
    }()
    
    
    required init(view: MessengerViewProtocol, service: UserServiceProtocol, conversationId: String?, brandId: String?, coordinator: MessagesCoordinatorProtocol) {
        self.view = view
        self.service = service
        self.conversationId = conversationId
        self.coordinator = coordinator
        
        if let brandId = brandId {
            print("\(brandId) setted")
            setBrandOptions(brandId: brandId)
        }
    }
    
    func setBrandOptions(brandId: String) {
        self.brandId = brandId
    }
    
    func viewDidLoad() {
        
    }
    
    func viewDidAppear() {
        listenMessages()
    }
    
    func getSelfSender() -> SenderType {
        guard let userId = SettingsService.sharedInstance.userId,
              let fullName = SettingsService.sharedInstance.userFullName,
              let firstName = fullName["firstName"] else {
            fatalError()
        }
        
        if let brandId = brandId, let brandName = SettingsService.sharedInstance.brandName {
            let brandSender = Sender(photoUrl: "", senderId: brandId, displayName: brandName)
            return brandSender
        } else {
            let userSender = Sender(photoUrl: "", senderId: userId, displayName: firstName)
            return userSender
        }
    }
    
    func getRecipientId() {
        
    }
    
    func didShowImagePicker() {
        coordinator?.showImagePicker()
    }
    
    func didShowImageDetailed(imageUrl: URL) {
        StorageService.sharedInstance.getImageFromUrl(imageUrl: imageUrl.absoluteString) { [weak self] result in
            switch result {
            case .success(let data):
                self?.coordinator?.showImageDetail(image: data)
            case .failure(_):
                fatalError("error with downloading data")
            }
        }
    }
    
    // create conversation with brand
    func createConversation(with text: String) {
        guard let brandId = self.brandId else {
            fatalError("unwrapping error")
        }
        
        let sender = getSelfSender()
        
        let message = Message(sender: sender, sentDate: Date(), kind: .text(text))
        
        FirestoreService.sharedInstance.getBrandName(brandId: brandId) { result in
            switch result {
            case .success(let brandName):
                RealTimeService.sharedInstance.createNewConversation(with: brandId, brandName: brandName, firstMessage: message) { result in
                    switch result {
                    case .success(let conversationId):
                        self.conversationId = conversationId
                        debugPrint("message sended")
                        self.listenMessages()
                    case .failure(let error):
                        fatalError("\(error)")
                    }
                }
            case .failure(let error):
                fatalError("\(error)")
            }
        }
    }
    
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
        let message = Message(sender: getSelfSender(), sentDate: Date(), kind: .text(text))
        
        
        guard let conversationId = self.conversationId else {
            createConversation(with: text); return
        }
        
        RealTimeService.sharedInstance.sendMessage(to: conversationId, newMessage: message, role: .user) { error in
            guard error == nil else {
                fatalError("\(error!)")
            }
            
            print("message sent with text: \(text)")
        }
    }
    
    func sendAttachment(image: Data) {
        StorageService.sharedInstance.uploadImage(with: image, type: .messageAttachment) { [weak self] result in
            switch result {
            case .success(let imageUrl):
                guard let url = URL(string: imageUrl),
                      let placeholder = UIImage(systemName: "plus"),
                      let selfSender = self?.getSelfSender(),
                      let conversationId = self?.conversationId else {
                    fatalError()
                }
                
                let media = Media(url: url, image: nil, placeholderImage: placeholder, size: .zero)
                let message = Message(sender: selfSender, sentDate: Date(), kind: .photo(media))
                
                RealTimeService.sharedInstance.sendMessage(to: conversationId, newMessage: message, role: .brand) { error in
                    guard error == nil else {
                        fatalError()
                    }
                    
                    print("attachment sended")
                }
                print(imageUrl)
            case .failure(let error):
                fatalError("\(error)")
            }
        }
    }
}

// MARK: - Dateformatter helpers
extension MessengerPresenter {
    public func convertFromDate(date: Date) -> String {
        dateFormatter.dateFormat = "HH:mm"
        let time = dateFormatter.string(from: date)
        dateFormatter.dateFormat = "d MMM"
        dateFormatter.locale = .current
        let date = dateFormatter.string(from: date)
        return "\(date), \(time)"
    }
}

extension MessengerPresenter: ImagePickerPresenterDelegate {
    func didCloseImagePicker(with imageData: Data) {
        self.sendAttachment(image: imageData)
    }
}
