import UIKit
import SPAlert

protocol FavoritesViewProtocol: AnyObject {
    func configureCollectionView()
    func configureDataSource()
    func configureViews()
    func insertFavorites(items: [Item])
    func getItemsInSnapshot() -> [Item]?
    func removeFavoriteItem(_ item: Item)
    func didSelectCell(_ item: Item)
    func showSuccessAlert()
}

class FavoritesViewController: UIViewController {
    var presenter: FavoritesPresenter!
    var favoritesView = FavoritesView()
    
    var collectionView: UICollectionView! = nil
    
    var dataSource: UICollectionViewDiffableDataSource<FavoritesView.Section, Item>?
    typealias DataSource = UICollectionViewDiffableDataSource<FavoritesView.Section, Item>
   
    //MARK: - Lifecycle
    
    override func loadView() {
        view = favoritesView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        presenter.viewDidLoad()
    }
}

extension FavoritesViewController: FavoritesViewProtocol {
    func configureCollectionView() {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: favoritesView.setupLayout())
        collectionView.backgroundColor = .white
        collectionView.delegate = self
        collectionView.register(FavoriteCell.self, forCellWithReuseIdentifier: FavoriteCell.reuseId)
        self.collectionView = collectionView
    }
    
    func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<FavoritesView.Section, Item>(collectionView: collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            let section = FavoritesView.Section.allCases[indexPath.section]
            switch section {
            case .favs:
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FavoriteCell.reuseId, for: indexPath) as? FavoriteCell else {
                    fatalError("dequeueReusableCell error with FavoriteCell")
                }
                
                cell.delegate = self
                cell.configure(with: itemIdentifier)
                return cell
            }
        })
        
        let snapshot = snapshotForCurrentState()
        dataSource?.apply(snapshot)
    }
    
    func snapshotForCurrentState() -> NSDiffableDataSourceSnapshot<FavoritesView.Section, Item> {
        var snapshot = NSDiffableDataSourceSnapshot<FavoritesView.Section, Item>()
        snapshot.appendSections([.favs])
        return snapshot
    }
    
    func configureViews() {
        view.addSubview(collectionView)
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.width.equalTo(view.snp.width)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
    }
    
    func getItemsInSnapshot() -> [Item]? {
        let snapshot = dataSource?.snapshot()
        let items = snapshot?.itemIdentifiers
        return items
    }
    
    func insertFavorites(items: [Item]) {
        var snapshot = dataSource?.snapshot()
        snapshot?.appendItems(items, toSection: .favs)
        dataSource?.apply(snapshot!)
    }
    
    func removeFavoriteItem(_ item: Item) {
        var snapshot = dataSource?.snapshot()
        snapshot?.deleteItems([item])
        dataSource?.apply(snapshot!)
    }
    
    func didSelectCell(_ item: Item) {
        presenter.openDetailed(with: item)
    }
    
    func showSuccessAlert() {
        SPAlert.present(title: "Успешно", message: "Товар был добавлен в корзину", preset: .done)
    }
}

extension FavoritesViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = dataSource?.itemIdentifier(for: indexPath) as? Item else {
            fatalError("didnt found itemIdentifier for indexPath")
        }
        
        self.didSelectCell(item)
    }
}

extension FavoritesViewController: FavoriteCellDelegate {
    func didTappedAddButton(_ favoriteCell: FavoriteCell) {
        guard let indexPath = collectionView.indexPath(for: favoriteCell),
              let item = dataSource?.itemIdentifier(for: indexPath) else {
            return
        }
        
        presenter.openSizePicker(item: item)
    }
    
    func didTappedRemoveButton(_ favoriteCell: FavoriteCell) {
        guard let indexPath = collectionView.indexPath(for: favoriteCell),
              let item = dataSource?.itemIdentifier(for: indexPath) else {
            return
        }
        
        presenter.removeFavoriteItem(item)
    }
}
