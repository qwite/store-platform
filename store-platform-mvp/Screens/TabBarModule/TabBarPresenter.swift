import Foundation

protocol TabBarPresenterProtocol {
    init(view: TabBarViewProtocol, coordinator: TabCoordinator)
}

class TabBarPresenter: TabBarPresenterProtocol {
    weak var view: TabBarViewProtocol?
    var coordinator: TabCoordinator
    
    required init(view: TabBarViewProtocol, coordinator: TabCoordinator) {
        self.view = view
        self.coordinator = coordinator
    }
}
