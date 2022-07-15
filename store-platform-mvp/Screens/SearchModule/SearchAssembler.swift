import UIKit

// MARK: - SearchAssembler
class SearchAssembler {
    static func buildSearchModule(coordinator: FeedCoordinator) -> UIViewController {
        let view = SearchViewController()
        let service = FeedService()
        let presenter = SearchPresenter(view: view, coordinator: coordinator, service: service)
        view.presenter = presenter
        return view
    }
}
