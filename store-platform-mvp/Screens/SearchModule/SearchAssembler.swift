import UIKit

// MARK: - SearchAssembler
class SearchAssembler {
    static func buildSearchModule(coordinator: FeedCoordinator, service: FeedServiceProtocol) -> UIViewController {
        let view = SearchViewController()
        let presenter = SearchPresenter(view: view, coordinator: coordinator, service: service)
        view.presenter = presenter
        return view
    }
}
