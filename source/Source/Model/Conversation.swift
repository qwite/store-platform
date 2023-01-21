import Foundation

struct Conversation: Hashable {
    let id: String
    let recipientName: String
    let lastMessage: String
    let date: String
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Conversation, rhs: Conversation) -> Bool {
        lhs.id == rhs.id
    }
}
