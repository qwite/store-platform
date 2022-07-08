import Foundation
import UIKit

protocol SearchPresenterProtocol {
    init(view: SearchViewProtocol, coordinator: FeedCoordinator, service: FeedServiceProtocol)
    func viewDidLoad()
    
    func searchItems(by category: String)
    func showResultsScreen(items: [Item])
}

class SearchPresenter: SearchPresenterProtocol {
    weak var view: SearchViewProtocol?
    weak var coordinator: FeedCoordinator?
    var service: FeedServiceProtocol?
    
    required init(view: SearchViewProtocol, coordinator: FeedCoordinator, service: FeedServiceProtocol) {
        self.view = view
        self.coordinator = coordinator
        self.service = service
    }
    
    func viewDidLoad() {
        view?.configureViews()
        view?.configureSearchController(parent: self.getParentController())
    }
    
    func searchItems(by category: String) {
        service?.fetchItemsByCategory(category: category) { [weak self] result in
            switch result {
            case .success(let items):
                self?.showResultsScreen(items: items)
            case .failure(_):
                self?.view?.showErrorAlert()
            }
        }
    }
    
    func getParentController() -> FeedViewController {
        guard let parentController = coordinator?.showSearchFeed() as? FeedViewController else {
            fatalError()
        }
        
        return parentController
    }
    
    func showResultsScreen(items: [Item]) {
        coordinator?.showFeed(with: items)
    }
    
    // TODO: Arc fixes
}
