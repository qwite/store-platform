import UIKit

protocol CartViewProtocol: AnyObject {
    func configureCollectionView()
    func configureDataSource()
    func configureViews()
    func insertItems(items: [CartItem])
    func removeItem(item: CartItem)
    func setTotalPrice(price: Int?)
}

class CartViewController: UIViewController {
    var cartView = CartView()
    var presenter: CartPresenter!
    var collectionView: UICollectionView! = nil
    var dataSource: UICollectionViewDiffableDataSource<CartView.Section, CartItem>?
    typealias DataSource = UICollectionViewDiffableDataSource<CartView.Section, CartItem>
    
    weak var delegate: TotalCartViewDelegate?
    //MARK: - Lifecycle
    
    override func loadView() {
        view = cartView
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presenter.viewDidAppear()
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
        collectionView.register(TotalCartView.self, forSupplementaryViewOfKind: CartView.SupplementaryKinds.totalCart.rawValue, withReuseIdentifier: TotalCartView.reuseId)
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
                cell.delegate = self
                cell.configure(cartItem: item)
                return cell
            }
        })
        
        dataSource?.supplementaryViewProvider = { (collectionView: UICollectionView, kind: String, indexPath: IndexPath) -> UICollectionReusableView? in
            switch kind {
            case "section-bottom-total-cart":
                guard let supplementaryView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: TotalCartView.reuseId, for: indexPath) as? TotalCartView else { fatalError("reuse error") }
                supplementaryView.configure()
                self.delegate = supplementaryView
                return supplementaryView
            default:
                return nil
            }
        }
        
//        let snapshot = snapshotForCurrentState()
//        dataSource?.apply(snapshot)
    }
    
    func snapshotForCurrentState() -> NSDiffableDataSourceSnapshot<CartView.Section, CartItem> {
        var snapshot = NSDiffableDataSourceSnapshot<CartView.Section, CartItem>()
        
        return snapshot
    }
    
    func insertItems(items: [CartItem]) {
        var snapshot = NSDiffableDataSourceSnapshot<CartView.Section, CartItem>()
        snapshot.appendSections([.cart])
        snapshot.appendItems(items, toSection: .cart)
        dataSource?.apply(snapshot)
    }
    
    func removeItem(item: CartItem) {
        var snapshot = dataSource?.snapshot()
        snapshot?.deleteItems([item])
        
        guard let availableItems = snapshot?.itemIdentifiers else {
            print("not found "); return
        }
        
        presenter.setTotalPrice(items: availableItems)
        
        dataSource?.apply(snapshot!)
    }
    
    func setTotalPrice(price: Int?) {
        guard let price = price else {
            return
        }
        
        delegate?.updateTotalPrice(price: price)
    }
}

// MARK: - UICollectionViewDelegate
extension CartViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        debugPrint("yeat")
    }
}

// MARK: - CartItemCellDelegate
extension CartViewController: CartItemCellDelegate {
    func didTappedRemoveButton(_ cell: UICollectionViewCell) {
        guard let indexPath = collectionView.indexPath(for: cell),
              let item = dataSource?.itemIdentifier(for: indexPath) else {
            fatalError("not founded indexPath or item in datasource")
        }
        
        self.removeItem(item: item)
        presenter.removeItem(item: item)
    }
}
