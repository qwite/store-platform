import UIKit

// MARK: - SortingAssembler
class SortingAssembler {
    static func buildSortingModule(coordinator: FeedCoordinator,
                                   service: FeedServiceProtocol,
                                   delegate: SortingFeedPresenterDelegate) -> UIViewController{
        let view = SortingFeedViewController()
        let presenter = SortingFeedPresenter(view: view, coordinator: coordinator, service: service)
        presenter.delegate = delegate
        view.presenter = presenter
        return view
    }
}
