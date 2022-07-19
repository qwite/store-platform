import UIKit
import SPAlert

// MARK: - SellerOrdersViewProtocol
protocol SellerOrdersViewProtocol: AnyObject {
    func configureCollectionView()
    func configureDataSource()
    func configureViews()
    
    func showErrorAlert()
    func insertItems(items: [Order])
}

// MARK: - SellerOrdersViewController
class SellerOrdersViewController: UIViewController {
    
    // MARK: Properties
    var presenter: SellerOrdersPresenterProtocol!
    var collectionView: UICollectionView! = nil
    var sellerOrdersView = SellerOrdersView()
    
    var dataSource: UICollectionViewDiffableDataSource<SellerOrdersView.Section, Order>?
    typealias DataSource = UICollectionViewDiffableDataSource<SellerOrdersView.Section, Order>
    
    // MARK: Lifecycle
    override func loadView() {
        view = sellerOrdersView
        title = "Заказы"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewDidLoad()
    }
}

// MARK: - SellerOrdersViewProtocol Implementation
extension SellerOrdersViewController: SellerOrdersViewProtocol {
    func configureCollectionView() {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: sellerOrdersView.configureLayout())
        collectionView.register(SellerOrdersCell.self, forCellWithReuseIdentifier: SellerOrdersCell.reuseId)
        collectionView.delegate = self
        
        self.collectionView = collectionView
    }
    
    func configureDataSource() {
        dataSource = DataSource(collectionView: collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            let sections = SellerOrdersView.Section.allCases[indexPath.section]
            switch sections {
            case .orders:
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SellerOrdersCell.reuseId, for: indexPath) as? SellerOrdersCell else { fatalError("dequeueReusableCell error") }
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
        var snapshot = NSDiffableDataSourceSnapshot<SellerOrdersView.Section, Order>()
        snapshot.appendSections([.orders])
        snapshot.appendItems(items)
        dataSource?.apply(snapshot)
    }
    
    func showErrorAlert() {
        SPAlert.present(message: "Заказы не найдены", haptic: .error)
    }
}

// MARK: - UICollectionViewDelegate
extension SellerOrdersViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = dataSource?.itemIdentifier(for: indexPath) else { return }
        presenter.showChangeStatus(order: item)
    }
}
