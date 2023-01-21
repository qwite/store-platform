import UIKit

// MARK: - SettingsAssembler
class SettingsAssembler {
    static func buildSettingsModule(coordinator: ProfileCoordinator) -> UIViewController {
        let view = SettingsViewController()
        let presenter = SettingsPresenter(view: view, coordinator: coordinator)
        view.presenter = presenter
        return view
    }
}
