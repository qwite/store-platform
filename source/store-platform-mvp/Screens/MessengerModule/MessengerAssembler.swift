import UIKit

// MARK: - MessengerAssembler
class MessengerAssembler {
    static func buildMessengerModule(conversationId: String?, recipientBrandId: String?, coordinator: MessagesCoordinatorProtocol) -> UIViewController {
        let view = MessengerViewController()
        let service = UserService()
        let presenter = MessengerPresenter(view: view,
                                           service: service,
                                           conversationId: conversationId,
                                           recipientBrandId: recipientBrandId,
                                           coordinator: coordinator)
        view.presenter = presenter
        return view
    }
}
