import Foundation

// MARK: - MessagesCoordinatorProtocol
protocol MessagesCoordinatorProtocol: AnyObject {
    func showListMessages()
    func showMessenger(conversationId: String?, brandId: String?)
    func showImagePicker()
    func showImageDetail(image: Data)
}
