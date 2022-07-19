import UIKit

// MARK: - TabBarAssembler
class TabBarAssembler {
    static func buildTabBarModule(coordinator: TabCoordinator) -> UITabBarController {
        let view = TabBarController()
        let presenter = TabBarPresenter(view: view, coordinator: coordinator)
        view.presenter = presenter
        return view
    }
}
