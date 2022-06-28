import Foundation
import FirebaseDatabase
import FirebaseFirestoreSwift
import MessageKit

class RealTimeService {
    static let sharedInstance = RealTimeService()
    private init() {}
    
    private let database = Database.database().reference()
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        formatter.timeZone = .current
        formatter.locale = Locale(identifier: "en_GB")
        return formatter
    }()
}

extension RealTimeService {
    public func insertUser(with user: CustomUser, completion: @escaping ((Error?) -> ())) {
        database.child(user.id!).setValue([
            "first_name": user.firstName,
            "last_name": user.lastName]) { error, _ in
                guard error == nil else {
                    completion(error!); return
                }
                
                completion(nil)
            }
    }
}

extension RealTimeService {
    public func createNode(for brandId: String, with brandName: String, completion: @escaping (Error?) -> ()) {
        let brandRef = database.child("\(brandId)")
        let value: [String: Any] = [
            "brand_name": brandName
        ]
        
        brandRef.setValue(value) { error, _ in
            guard error == nil else {
                return completion(error!)
            }
            
            completion(nil)
        }
    }
    
    
    /// new conversation with user and brand
    public func createNewConversation(with brandId: String, brandName: String, firstMessage: Message, completion: @escaping (Result<String, Error>) -> ()) {
        guard let userId = SettingsService.sharedInstance.userId,
              let fullName = SettingsService.sharedInstance.userFullName,
              let userName = fullName["firstName"] else {
            return
        }
        
        let userRef = database.child("\(userId)")
        userRef.observeSingleEvent(of: .value) { [weak self] snapshot in
            guard var userNode = snapshot.value as? [String: Any] else {
                fatalError()
            }
            
            let conversationId = UUID().uuidString
            let messageDate = firstMessage.sentDate
            let messageDateString = self?.dateFormatter.string(from: messageDate)
            
            var message = ""
            
            switch firstMessage.kind {
            case .text(let messageText):
                message = messageText
            case .attributedText(_):
                break
            case .photo(_):
                break
            case .video(_):
                break
            case .location(_):
                break
            case .emoji(_):
                break
            case .audio(_):
                break
            case .contact(_):
                break
            case .linkPreview(_):
                break
            case .custom(_):
                break
            }
            
            let newConversationData: [String: Any] = [
                "id": conversationId,
                "brand_id": brandId,
                "brand_name": brandName,
                "latest_message": [
                    "date": messageDateString,
                    "message": message,
                    "is_read": false
                ]
            ]
            
            let recipientConversationData: [String: Any] = [
                "id": conversationId,
                "user_id": userId,
                "user_name": userName,
                "latest_message": [
                    "date": messageDateString,
                    "message": message,
                    "is_read": false
                ]
            ]
            
            // TODO: append conversations check
            self?.database.child("\(brandId)").setValue([
                "conversations": [recipientConversationData]
            ])
            
            userNode["conversations"] = [
                newConversationData
            ]
            
            
            userRef.setValue(userNode) { [weak self] error, _ in
                guard error == nil else {
                    return completion(.failure(error!))
                }
                
                self?.finishCreatingConversation(userId: userId, conversationId: conversationId, firstMessage: firstMessage, completion: { error in
                    guard error == nil else {
                        return completion(.failure(error!))
                    }
                    
                    completion(.success(conversationId))
                })
                
            }
        }
    }
    
    public func getAllConversationsForBrand(brandId: String, completion: @escaping (Result<[Conversation], Error>) -> ()) {
        database.child(brandId).child("conversations").observe(.value) { snapshot in
            guard let value = snapshot.value as? [[String: Any]] else {
                return completion(.failure(RealTimeServiceError.failedToFetchConversations))
            }
            
            // TODO: Add date, isRead bool
            let conversations: [Conversation] = value.compactMap { dictionary in
                guard let id = dictionary["id"] as? String,
                      let latestMessage = dictionary["latest_message"] as? [String: Any],
                      let userName = dictionary["user_name"] as? String else {
                    return nil
                }
                
                guard let lastMessage = latestMessage["message"] as? String,
                      let dateString = latestMessage["date"] as? String else {
                    fatalError()
                }
                
                let conversation = Conversation(id: id, recipientName: userName, lastMessage: lastMessage, date: dateString)
                return conversation
            }
            
            completion(.success(conversations))
        }
    }
    
    public func getAllConversationsForUser(userId: String, completion: @escaping (Result<[Conversation], Error>) -> ()) {
        database.child(userId).child("conversations").observe(.value) { snapshot in
            guard let value = snapshot.value as? [[String: Any]] else {
                return completion(.failure(RealTimeServiceError.failedToFetchConversations))
            }
            
            let conversations: [Conversation] = value.compactMap { dictionary in
                guard let id = dictionary["id"] as? String,
                      let latestMessage = dictionary["latest_message"] as? [String: Any],
                      let brandName = dictionary["brand_name"] as? String else {
                    return nil
                }
                guard let lastMessage = latestMessage["message"] as? String,
                      let dateString = latestMessage["date"] as? String else {
                    fatalError()
                }
                
                
                let conversation = Conversation(id: id, recipientName: brandName, lastMessage: lastMessage, date: dateString)
                return conversation
            }
            
            completion(.success(conversations))
        }
    }
    
    public func getAllMessagesForConversation(with conversationId: String, completion: @escaping (Result<[Message], Error>) -> ()) {
        database.child("conversations").child("\(conversationId)/messages").observe(.value) { snapshot in
            guard let value = snapshot.value as? [[String: Any]] else {
                return completion(.failure(RealTimeServiceError.failedToFetchMesssages))
            }
            
            let messages: [Message] = value.compactMap { dictionary in
                guard let id = dictionary["id"] as? String,
                      let content = dictionary["content"] as? String,
                      let dateString = dictionary["date"] as? String,
                      let name = dictionary["name"] as? String,
                      let date = self.dateFormatter.date(from: dateString),
                      let isRead = dictionary["is_read"] as? Bool,
                      let senderId = dictionary["sender_id"] as? String,
                      let senderRole = dictionary["sender_role"] as? String,
                      let type = dictionary["type"] as? String else {
                    return nil
                }
                
                // FIXME: edit
                let sender = Sender(photoUrl: "", senderId: senderId, displayName: name)
                let finalKind: MessageKind?
                
                switch type {
                case "text":
                    finalKind = .text(content)
                case "photo":
                    guard let url = URL(string: content),
                          let placeholder = UIImage(systemName: "plus") else {
                        return nil
                    }
                    
                    let media = Media(url: url, image: nil, placeholderImage: placeholder, size: .init(width: 150, height: 150))
                    finalKind = .photo(media)
                default:
                    finalKind = .text(content)
                }
                
                guard let finalKind = finalKind else {
                    fatalError()
                }
                
                return Message(sender: sender,
                               sentDate: date,
                               kind: finalKind,
                               messageId: id)
            }
            
            completion(.success(messages))
        }
    }
    
    public func sendMessage(to conversationId: String, newMessage: Message, role: ChatRole, completion: @escaping (Error?) -> ()) {
        database.child("conversations").child("\(conversationId)/messages").observeSingleEvent(of: .value) { [weak self] snapshot in
            guard let strongSelf = self else {
                return
            }
            
            guard var currentMessages = snapshot.value as? [[String: Any]] else {
                return completion(RealTimeServiceError.failedToFetchMesssages)
            }
            
            let messageDate = newMessage.sentDate
            let messageDateString = strongSelf.dateFormatter.string(from: messageDate)
            
            var message = ""
            
            switch newMessage.kind {
            case .text(let messageText):
                message = messageText
            case .attributedText(_):
                break
            case .photo(let mediaItem):
                if let urlString = mediaItem.url?.absoluteString {
                    message = urlString
                }
                
                break
            case .video(_):
                break
            case .location(_):
                break
            case .emoji(_):
                break
            case .audio(_):
                break
            case .contact(_):
                break
            case .linkPreview(_):
                break
            case .custom(_):
                break
            }
            
            let newMessageData: [String: Any] = [
                "content": message,
                "date": messageDateString,
                "id": newMessage.messageId,
                "is_read": false,
                "name": newMessage.sender.displayName,
                "sender_id": newMessage.sender.senderId,
                "sender_role": role.rawValue,
                "type": newMessage.kind.messageKindString
            ]
            
            currentMessages.append(newMessageData)
            
            strongSelf.database.child("conversations").child("\(conversationId)/messages").setValue(currentMessages) { error, _ in
                guard error == nil else {
                    return completion(error!)
                }
                
                let latestMessageData: [String: Any] = ["date": messageDateString,
                                                        "is_read": false,
                                                        "message": message]
                
                strongSelf.updateLatestMessage(conversationId: conversationId, id: newMessage.sender.senderId, messageData: latestMessageData) { error in
                    guard error == nil else {
                        return completion(error!)
                    }
                    
                    completion(nil)
                }
            }
            
        }
    }
    
    // MARK: - Private methods
    
    private func finishCreatingConversation(userId: String, conversationId: String, firstMessage: Message, completion: @escaping (Error?) -> ()) {
        var message = ""
        let messageDate = firstMessage.sentDate
        let messageDateString = self.dateFormatter.string(from: messageDate)
        
        switch firstMessage.kind {
        case .text(let messageText):
            message = messageText
        case .attributedText(_):
            break
        case .photo(_):
            break
        case .video(_):
            break
        case .location(_):
            break
        case .emoji(_):
            break
        case .audio(_):
            break
        case .contact(_):
            break
        case .linkPreview(_):
            break
        case .custom(_):
            break
        }
        
        let messageData: [String: Any] = [
            "id": firstMessage.messageId,
            "type": firstMessage.kind.messageKindString,
            "content": message,
            "date": messageDateString,
            "sender_id": userId,
            "sender_role": "user",
            "is_read": false,
            "name": firstMessage.sender.displayName
        ]
        
        let value: [String: Any] = [
            "messages": [
                messageData
            ]
        ]
        
        let ref = database.child("conversations").child("\(conversationId)")
        
        ref.setValue(value) { error, snapshot in
            guard error == nil else {
                fatalError()
            }
            
            completion(nil)
        }
    }
    
    private func updateLatestMessage(conversationId: String, id: String, messageData: [String: Any], completion: @escaping (Error?) -> ()) {
        var recipientId: String?
        
        // for sender
        database.child("\(id)/conversations").observeSingleEvent(of: .value) { snapshot in
            guard var senderConversations = snapshot.value as? [[String: Any]] else {
                return completion(RealTimeServiceError.failedToFetchConversations)
            }
            
            var targetConversation: [String: Any]?
            var position = 0
            
            for conversation in senderConversations {
                if let recipient = conversation["user_id"] as? String {
                    recipientId = recipient
                } else {
                    recipientId = conversation["brand_id"] as! String
                }
                
                if let dictId = conversation["id"] as? String, dictId == conversationId {
                    targetConversation = conversation
                    break
                }
                position += 1
            }
            
            targetConversation?["latest_message"] = messageData
            guard let finalConversation = targetConversation else {
                fatalError("unwrapping error")
            }
            
            senderConversations[position] = finalConversation
            // set new values
            self.database.child("\(id)/conversations").setValue(senderConversations) { error, _ in
                guard error == nil else {
                    return completion(error!)
                }
            }
            
            // for recipient
            guard let recipientId = recipientId else {
                fatalError("recipient not updated")
            }
            
            self.database.child("\(recipientId)/conversations").observeSingleEvent(of: .value) { snapshot in
                guard var recipientConversation = snapshot.value as? [[String: Any]] else {
                    return completion(RealTimeServiceError.failedToFetchConversations)
                }
                
                var targetConversation: [String: Any]?
                var position = 0
                
                for conversation in recipientConversation {
                    if let dictId = conversation["id"] as? String, dictId == conversationId {
                        targetConversation = conversation
                        break
                    }
                    position += 1
                }
                
                targetConversation?["latest_message"] = messageData
                guard let finalConversation = targetConversation else {
                    fatalError("unwrapping error")
                }
                
                recipientConversation[position] = finalConversation
                
                self.database.child("\(recipientId)/conversations").setValue(recipientConversation) { error, _ in
                    guard error == nil else {
                        return completion(error)
                    }
                    completion(nil)
                }
            }
        }
    }
}

extension RealTimeService {
    enum RealTimeServiceError: Error {
        case failedToFetchConversations
        case failedToFetchMesssages
        case failedToSendMessage
    }
}

extension RealTimeService {
    enum ChatRole: String {
        case user = "user"
        case brand = "brand"
    }
}