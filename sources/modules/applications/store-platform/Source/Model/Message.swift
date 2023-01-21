import Foundation
import FirebaseFirestoreSwift
import UIKit
import MessageKit

struct Sender: SenderType {
   public var photoUrl: String? = nil
   public var senderId: String
   public var displayName: String
}

struct Message: MessageType {
    var sender: SenderType
    var sentDate: Date
    var kind: MessageKind
    var messageId: String = UUID().uuidString
}

struct Media: MediaItem {
    var url: URL?
    var image: UIImage?
    var placeholderImage: UIImage
    var size: CGSize
}

extension MessageKind {
    var messageKind: String? {
        switch self {
        case .text(_):
            return "text"
        case .attributedText(_):
            return "attributed_text"
        case .photo(_):
            return "photo"
        case .video(_):
            return "video"
        case .location(_):
            return "location"
        case .emoji(_):
            return "emoji"
        case .audio(_):
            return "audio"
        case .contact(_):
            return "contact"
        case .linkPreview(_):
            return "link_preview"
        case .custom(_):
            return "custom"
        }
    }
    
    var messageContent: String? {
        switch self {
        case .text(let messageText):
            return messageText
        case .attributedText(_):
            return "attributed_text"
        case .photo(let mediaItem):
            if let urlString = mediaItem.url?.absoluteString {
                return urlString
            }
        case .video(_):
            return "video"
        case .location(_):
            return "location"
        case .emoji(_):
            return "emoji"
        case .audio(_):
            return "audio"
        case .contact(_):
            return "contact"
        case .linkPreview(_):
            return "link_preview"
        case .custom(_):
            return "custom"
        }
        return nil
    }
}
