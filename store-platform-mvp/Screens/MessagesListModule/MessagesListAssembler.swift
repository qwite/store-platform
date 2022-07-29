import UIKit

// MARK: - MessagesListAssembler
class MessagesListAssembler {
    static func buildMessagesListModule(role: MessengerRole, coordinator: MessagesCoordinatorProtocol) -> UIViewController {
        let view = MessagesListViewController()
        let service = BrandService()
        let presenter = MessagesListPresenter(view: view, role: role, service: service, coordinator: coordinator)
        view.presenter = presenter
        return view
    }
}
