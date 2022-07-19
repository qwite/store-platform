import UIKit

// MARK: - MessengerAssembler
class MessengerAssembler {
    static func buildMessengerModule(conversationId: String?, brandId: String?, coordinator: MessagesCoordinatorProtocol) -> UIViewController {
        let view = MessengerViewController()
        let service = UserService()
        let presenter = MessengerPresenter(view: view, service: service, conversationId: conversationId, brandId: brandId, coordinator: coordinator)
        view.presenter = presenter
        return view
    }
}
