import UIKit

protocol FeedViewProtocol: AnyObject {
    func configureCollectionView()
    func configureDataSource()
    func configureViews()
    func configureButtons()
    func insertAds(items: [Item])
    func removeSearchBar(category: String)
    func searchFilter(text: String)
    func updateDataSource(with items: [Item])
}

class FeedViewController: UIViewController {
    var feedView = FeedView()
    var presenter: FeedPresenter!
    
    var collectionView: UICollectionView! = nil
    let searchController = UISearchController()
    var dataSource: UICollectionViewDiffableDataSource<FeedView.Section, Item>?
    typealias DataSource = UICollectionViewDiffableDataSource<FeedView.Section, Item>
    
    override func loadView() {
        view = feedView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewDidLoad()
    }
    
    deinit {
        debugPrint("feed vc deinit")
    }
}

extension FeedViewController: FeedViewProtocol {
    func configureCollectionView() {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: feedView.configureLayout())
        collectionView.backgroundColor = .white
        collectionView.delegate = self
        collectionView.register(AdCell.self, forCellWithReuseIdentifier: AdCell.reuseId)
        self.collectionView = collectionView
    }
    
    func configureDataSource() {
        dataSource = DataSource(collectionView: collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            let section = FeedView.Section.allCases[indexPath.section]
            switch section {
            case .ads:
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AdCell.reuseId, for: indexPath) as? AdCell else {
                    fatalError("dequeueReusableCell error with AdCell")
                }
                
                cell.delegate = self
                cell.configure(with: itemIdentifier)
                return cell
            }
        })
        
//        let snapshot = snapshotForCurrentState()
//        dataSource?.apply(snapshot)
    }
//
//    func snapshotForCurrentState() -> NSDiffableDataSourceSnapshot<FeedView.Section, Item> {
//        var snapshot = NSDiffableDataSourceSnapshot<FeedView.Section, Item>()
//        snapshot.appendSections([.ads])
//        return snapshot
//    }
    
    func insertAds(items: [Item]) {
        var snapshot = NSDiffableDataSourceSnapshot<FeedView.Section, Item>()
        snapshot.appendSections([.ads])
        snapshot.appendItems(items)
        dataSource?.apply(snapshot)
    }
    
    func removeSearchBar(category: String) {
        self.searchController.searchBar.removeFromSuperview()
        self.navigationItem.searchController = nil
        self.title = category
    }
    
    func configureButtons() {
        feedView.sortButton.addTarget(self, action: #selector(sortButtonAction), for: .touchUpInside)
    }
    
    @objc private func sortButtonAction() {
        presenter.openSortingFeed()
    }
    
    func configureViews() {
        feedView.backgroundColor = .white
        
        view.addSubview(collectionView)
        view.addSubview(feedView.sortButton)
        
        searchController.searchBar.placeholder = "Поиск"
        searchController.searchBar.delegate = self
        self.navigationItem.searchController = searchController
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.width.equalTo(view.snp.width)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }

        feedView.sortButton.snp.makeConstraints { make in
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).offset(-55)
            make.centerX.equalTo(view.snp.centerX)
            make.height.equalTo(30)
            make.width.equalTo(158)
        }
    }
    
    func searchFilter(text: String) {
        presenter.searchItems(by: text.lowercased())
    }
    
    func updateDataSource(with items: [Item]) {
        var snapshot = NSDiffableDataSourceSnapshot<FeedView.Section, Item>()

        snapshot.appendSections([.ads])
        snapshot.appendItems(items)
        dataSource?.apply(snapshot, animatingDifferences: true)
    }
}

extension FeedViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = dataSource?.itemIdentifier(for: indexPath) else {
            fatalError("item not found in datasource")
        }
        presenter.openDetailed(item: item)
    }
}

extension FeedViewController: AdCellDelegate {
    func didTappedLikeButton(_ adCell: AdCell) {
        guard let indexPath = collectionView.indexPath(for: adCell),
              let item = dataSource?.itemIdentifier(for: indexPath) else {
            return
        }
        
        presenter.addFavorite(item: item)
    }
    
    func didUntappedLikeButton(_ adCell: AdCell) {
        guard let indexPath = collectionView.indexPath(for: adCell),
              let item = dataSource?.itemIdentifier(for: indexPath) else {
            return
        }
    
        presenter.removeFavorite(item: item)
    }
}

// MARK: - UISearchBarDelegate
extension FeedViewController: UISearchBarDelegate {
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        presenter.openSearch()
        return false
    }
}

// MARK: - UISearchResultsUpdating
extension FeedViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        let items = dataSource?.snapshot().itemIdentifiers
        if items?.count == 0 {
            print("ZE")
        }
        
        let text = searchController.searchBar.text ?? ""
        if text.isEmpty { presenter.fetchItems() }
        self.searchFilter(text: text)
    }
}
