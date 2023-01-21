import UIKit

// MARK: - SettingsViewProtocol
protocol SettingsViewProtocol: AnyObject {
    func configure()
}

// MARK: - SettingsViewController
class SettingsViewController: UIViewController {
    var presenter: SettingsPresenterProtocol!
    var settingsView = SettingsView()
    
    // MARK: Lifecycle
    override func loadView() {
        view = settingsView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Настройки"
        presenter.viewDidLoad()
    }
}

// MARK: - SettingsViewProtocol Implementation
extension SettingsViewController: SettingsViewProtocol {
    func configure() {
        settingsView.configure()
    }
}
