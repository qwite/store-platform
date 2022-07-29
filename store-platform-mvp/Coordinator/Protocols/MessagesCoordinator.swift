import Foundation

// MARK: - MessagesCoordinatorProtocol
protocol MessagesCoordinatorProtocol: AnyObject, ImageCoordinatorProtocol {
    var finishFlow: (() -> (Void))? { get set }
    
    func showListMessages()
    func showMessenger(conversationId: String?, brandId: String?)
}
