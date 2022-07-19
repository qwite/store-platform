import Foundation

// MARK: - SettingsPresenterProtocol
protocol SettingsPresenterProtocol {
    init(view: SettingsViewProtocol, coordinator: ProfileCoordinator)
    func viewDidLoad()
}

// MARK: - SettingsPresenterProtocol Implementation
class SettingsPresenter: SettingsPresenterProtocol {
    weak var view: SettingsViewProtocol?
    weak var coordinator: ProfileCoordinator?
    
    required init(view: SettingsViewProtocol, coordinator: ProfileCoordinator) {
        self.view = view
        self.coordinator = coordinator
    }
    
    func viewDidLoad() {
        view?.configure()
    }
}
