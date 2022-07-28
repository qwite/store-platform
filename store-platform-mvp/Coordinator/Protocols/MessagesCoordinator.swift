import Foundation

// MARK: - MessagesCoordinatorProtocol
protocol MessagesCoordinatorProtocol: AnyObject, ImageCoordinatorProtocol {
    func showListMessages()
    func showMessenger(conversationId: String?, brandId: String?)
}
