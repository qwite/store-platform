import UIKit
import SPAlert

// MARK: - UserOrdersViewProtocol
protocol UserOrdersViewProtocol: AnyObject {
    func configureCollectionView()
    func configureDataSource()
    func configureViews()
    
    func insertItems(items: [Order])
    func getItemsInSnapshot() -> [Order]?
    func showErrorAlert()
}

// MARK: - UserOrdersViewController
class UserOrdersViewController: UIViewController {
    var presenter: UserOrdersPresenterProtocol!
    
    var userOrdersView = UserOrdersView()
    var collectionView: UICollectionView! = nil
    
    var dataSource: UICollectionViewDiffableDataSource<UserOrdersView.Section, Order>?
    typealias DataSource = UICollectionViewDiffableDataSource<UserOrdersView.Section, Order>
    
    // MARK: Lifecycle
    override func loadView() {
        view = userOrdersView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewDidLoad()
        title = "Мои заказы"
    }
}

// MARK: - UserOrdersViewProtocol Implementation
extension UserOrdersViewController: UserOrdersViewProtocol {
    func configureCollectionView() {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: userOrdersView.configureLayout())
        collectionView.register(OrderCell.self, forCellWithReuseIdentifier: OrderCell.reuseId)
        collectionView.delegate = self 
        self.collectionView = collectionView
    }
    
    func configureDataSource() {
        dataSource = DataSource(collectionView: collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            let sections = UserOrdersView.Section.allCases[indexPath.section]
            switch sections {
            case .orders:
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OrderCell.reuseId, for: indexPath) as? OrderCell else { fatalError("dequeueReusableCell error)") }
                
                cell.configure(order: itemIdentifier)
                return cell
            }
        })
    }
    
    func configureViews() {
        view.backgroundColor = .white
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalTo(view.snp.edges)
        }
    }
    
    func insertItems(items: [Order]) {
        var snapshot = NSDiffableDataSourceSnapshot<UserOrdersView.Section, Order>()
        snapshot.appendSections([.orders])
        snapshot.appendItems(items)
        dataSource?.apply(snapshot)
    }
    
    func getItemsInSnapshot() -> [Order]? {
        guard let snapshot = dataSource?.snapshot() else { return nil }
        return snapshot.itemIdentifiers
    }
    
    func showErrorAlert() {
        SPAlert.present(message: "У вас еще нет заказов", haptic: .error)
    }
}

// MARK: - UICollectionViewDelegate
extension UserOrdersViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = dataSource?.itemIdentifier(for: indexPath) else { return }
        
        presenter.showDetailed(with: item)
    }
}
