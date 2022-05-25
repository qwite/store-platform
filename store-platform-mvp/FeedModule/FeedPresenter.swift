import Foundation

protocol FeedPresenterProtocol: AnyObject {
    init(view: FeedViewProtocol, coordinator: FeedCoordinator)
    func viewDidLoad()
    func getAds()
}

class FeedPresenter: FeedPresenterProtocol {
    var view: FeedViewProtocol
    var coordinator: FeedCoordinator
    
    required init(view: FeedViewProtocol, coordinator: FeedCoordinator) {
        self.view = view
        self.coordinator = coordinator
    }
    
    func viewDidLoad() {
        view.configureCollectionView()
        view.configureDataSource()
        view.configureViews()
        getAds()
    }
    
    func getAds() {
        FirestoreService.sharedInstance.getAllItems { result in
            switch result {
            case .success(let items):
//                debugPrint(items)
                self.view.insertAds(items: items)
            case .failure(let error):
                debugPrint(error)
            }
        }
    }
}
