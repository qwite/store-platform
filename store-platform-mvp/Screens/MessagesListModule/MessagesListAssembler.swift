import UIKit

// MARK: - MessagesListAssembler
class MessagesListAssembler {
    static func buildMessagesListModule(role: RealTimeService.ChatRole, coordinator: MessagesCoordinatorProtocol) -> UIViewController {
        let view = MessagesListViewController()
        let service = BrandService()
        let presenter = MessagesListPresenter(view: view, role: role, service: service, coordinator: coordinator)
        view.presenter = presenter
        return view
    }
}
