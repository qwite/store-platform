import UIKit
import SPAlert

// MARK: - SubscriptionsViewProtocol
protocol SubscriptionsViewProtocol: AnyObject {
    func configureCollectionView()
    func configureDataSource()
    func configureLayout() -> UICollectionViewLayout
    func configureViews()
    func insertSubscriptions(items: [String])
    func showErrorAlert()
}

// MARK: - SubscriptionsViewController
class SubscriptionsViewController: UIViewController {
    var presenter: SubscriptionsPresenter!
    var collectionView: UICollectionView! = nil
    var dataSource: UICollectionViewDiffableDataSource<Sections, AnyHashable>?
    typealias DataSource = UICollectionViewDiffableDataSource<Sections, AnyHashable>
    
    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewDidLoad()
        
        view.backgroundColor = .white
        title = "Мои подписки"
    }
}

// MARK: - SubscriptionsViewProtocol Implementation
extension SubscriptionsViewController: SubscriptionsViewProtocol {
    func configureCollectionView() {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: configureLayout())
        collectionView.register(SubscriptionCell.self, forCellWithReuseIdentifier: SubscriptionCell.reuseId)
        
        self.collectionView = collectionView
    }
    
    func configureLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .absolute(40))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 20.0
        section.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 20, bottom: 0, trailing: 20)
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
    
    func configureDataSource() {
        dataSource = DataSource(collectionView: collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            let section = Sections.allCases[indexPath.section]
            switch section {
            case .subscriptions:
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SubscriptionCell.reuseId, for: indexPath) as? SubscriptionCell else { fatalError() }
                cell.delegate = self
                cell.configure(brandName: itemIdentifier.description)
                return cell
            }
        })
    }
    
    func configureViews() {
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalTo(view.snp.edges)
        }
    }
    
    func insertSubscriptions(items: [String]) {
        var snapshot = NSDiffableDataSourceSnapshot<Sections, AnyHashable>()
        snapshot.appendSections([.subscriptions])
        snapshot.appendItems(items)
        dataSource?.apply(snapshot)
    }
    
    func showErrorAlert() {
        SPAlert.present(message: Constants.Errors.subscriptionsNotExist, haptic: .error)
    }

}

// MARK: - Sections
extension SubscriptionsViewController {
    enum Sections: Int, CaseIterable {
        case subscriptions
    }
}

// MARK: - SubscriptionCellDelegate
extension SubscriptionsViewController: SubscriptionCellDelegate {
    func didTappedRemoveButton(_ cell: UICollectionViewCell) {
        guard let indexPath = collectionView.indexPath(for: cell),
              let item = dataSource?.itemIdentifier(for: indexPath) as? String else { fatalError() }
        
        presenter.removeSubscription(brandName: item)
    }
}
