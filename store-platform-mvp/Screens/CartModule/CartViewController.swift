import UIKit

protocol CartViewProtocol: AnyObject {
    func configureCollectionView()
    func configureDataSource()
    func configureViews()
    func insertItems(items: [CartItem])
}

class CartViewController: UIViewController {
    var cartView = CartView()
    var presenter: CartPresenter!
    var collectionView: UICollectionView! = nil
    var dataSource: UICollectionViewDiffableDataSource<CartView.Section, CartItem>?
    typealias DataSource = UICollectionViewDiffableDataSource<CartView.Section, CartItem>
    //MARK: - Lifecycle
    
    override func loadView() {
        view = cartView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewDidLoad()
    }
}

extension CartViewController: CartViewProtocol {
    func configureViews() {
        cartView.backgroundColor = .white
        view.addSubview(collectionView)
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.width.equalTo(view.snp.width)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
    }
    
    func configureCollectionView() {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: cartView.configureLayout())
        collectionView.backgroundColor = .white
        collectionView.delegate = self
        collectionView.register(CartItemCell.self, forCellWithReuseIdentifier: CartItemCell.reuseId)
        self.collectionView = collectionView
    }
    
    func configureDataSource() {
        dataSource = DataSource(collectionView: self.collectionView, cellProvider: { (collectionView, indexPath, itemIdentifier) -> UICollectionViewCell in
            let section = CartView.Section.allCases[indexPath.section]
            switch section {
            case .cart:
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CartItemCell.reuseId, for: indexPath) as? CartItemCell else {
                    fatalError("dequeue error")
                }
                
                let item = itemIdentifier
                
                cell.configure(cartItem: item)
                return cell
            }
        })
        
        let snapshot = snapshotForCurrentState()
        dataSource?.apply(snapshot)
    }
    
    func snapshotForCurrentState() -> NSDiffableDataSourceSnapshot<CartView.Section, CartItem> {
        var snapshot = NSDiffableDataSourceSnapshot<CartView.Section, CartItem>()
        snapshot.appendSections([.cart])
        return snapshot
    }
    
    func insertItems(items: [CartItem]) {
        var snapshot = dataSource?.snapshot()
        snapshot?.appendItems(items, toSection: .cart)
        dataSource?.apply(snapshot!)
    }
}

extension CartViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        debugPrint("yeat")
    }
}
