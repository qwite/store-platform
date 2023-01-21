import Foundation
import UIKit

// MARK: - SubscriptionsAssembler
class SubscriptionsAssembler {
    static func buildSubscriptionsModule(coordinator: ProfileCoordinator) -> UIViewController {
        let service = UserService()
        let view = SubscriptionsViewController()
        let presenter = SubscriptionsPresenter(view: view, coordinator: coordinator, service: service)
        view.presenter = presenter
        return view
    }
}
