import UIKit
import SPAlert

protocol SearchViewProtocol: AnyObject {
    func configureViews()
    func configureSearchController(parent: FeedViewController)
    func showErrorAlert()
}

class SearchViewController: UIViewController {
    private var searchController: UISearchController?
    let searchView = SearchView()
    var presenter: SearchPresenterProtocol!
    
    // MARK: Lifecycle
    
    override func loadView() {
        view = searchView
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewDidLoad()
        searchView.delegate = self
    }
}

extension SearchViewController: SearchViewProtocol {
    func configureViews() {
        title = "Поиск"
        searchView.configure()
    }
    
    func configureSearchController(parent: FeedViewController) {
        self.searchController = UISearchController(searchResultsController: parent)
        self.searchController?.showsSearchResultsController = true
        self.searchController?.searchResultsUpdater = parent
        self.searchController?.searchBar.placeholder = "Поиск"
        self.searchController?.searchBar.delegate = self
        self.navigationItem.searchController = searchController
    }
    
    func showErrorAlert() {
        SPAlert.present(message: "Товары не найдены", haptic: .error)
    }
}

extension SearchViewController: SearchViewDelegate {
    func didTappedCategoryButton(_ category: String) {
        presenter.searchItems(by: category)
    }
}

extension SearchViewController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
    }
}
