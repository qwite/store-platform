import UIKit

protocol SettingsViewProtocol: AnyObject {
    func configure()
}

class SettingsViewController: UIViewController {
    var presenter: SettingsPresenterProtocol!
    var settingsView = SettingsView()
    
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

extension SettingsViewController: SettingsViewProtocol {
    func configure() {
        settingsView.configure()
    }
}
