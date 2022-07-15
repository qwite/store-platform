import UIKit

// MARK: - CartViewProtocol
protocol CartViewProtocol: AnyObject {
    func configureCollectionView()
    func configureDataSource()
    func configureViews()
    func insertItems(items: [Cart])
    func removeItem(item: Cart)
    func setTotalPrice(price: Int?)
    func getItemsCart() -> [Cart]?
}

// MARK: - CartViewDelegate
protocol CartViewDelegate: AnyObject {
    func didTappedTotalButton()
}

// MARK: - CartViewController
class CartViewController: UIViewController {
    var cartView = CartView()
    var presenter: CartPresenter!
    var collectionView: UICollectionView! = nil
    var dataSource: UICollectionViewDiffableDataSource<CartView.Section, Cart>?
    typealias DataSource = UICollectionViewDiffableDataSource<CartView.Section, Cart>
    
    weak var delegate: TotalCartViewDelegate?
    //MARK: Lifecycle
    
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

// MARK: - CartViewProtocol Implementation
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
        collectionView.register(CartCell.self, forCellWithReuseIdentifier: CartCell.reuseId)
        collectionView.register(TotalCartView.self, forSupplementaryViewOfKind: CartView.SupplementaryKinds.totalCart.rawValue, withReuseIdentifier: TotalCartView.reuseId)
        self.collectionView = collectionView
    }
    
    func configureDataSource() {
        dataSource = DataSource(collectionView: self.collectionView, cellProvider: { [weak self] (collectionView, indexPath, itemIdentifier) -> UICollectionViewCell in
            let section = CartView.Section.allCases[indexPath.section]
            switch section {
            case .cart:
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CartCell.reuseId, for: indexPath) as? CartCell else {
                    fatalError("dequeue error")
                }
                
                let cartItem = itemIdentifier
                cell.delegate = self
                
                self?.presenter.getItem(id: cartItem.itemId) { item in
                    cell.configure(cartItem: cartItem, fetchedItem: item)
                }

                return cell
            }
        })
        
        dataSource?.supplementaryViewProvider = { (collectionView: UICollectionView, kind: String, indexPath: IndexPath) -> UICollectionReusableView? in
            switch kind {
            case "section-bottom-total-cart":
                guard let supplementaryView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: TotalCartView.reuseId, for: indexPath) as? TotalCartView else { fatalError("reuse error") }
                supplementaryView.configure()
               //  FIXME:  retain cycle?
                self.delegate = supplementaryView
                supplementaryView.delegate = self
                return supplementaryView
            default:
                return nil
            }
        }
    }
    
    func insertItems(items: [Cart]) {
        var snapshot = NSDiffableDataSourceSnapshot<CartView.Section, Cart>()
        snapshot.appendSections([.cart])
        snapshot.appendItems(items, toSection: .cart)
        dataSource?.apply(snapshot)
    }
    
    func removeItem(item: Cart) {
        var snapshot = dataSource?.snapshot()
        snapshot?.deleteItems([item])
        
        guard let availableItems = snapshot?.itemIdentifiers else {
            print("not found "); return
        }
        
        presenter.setTotalPrice(items: availableItems)
        
        dataSource?.apply(snapshot!)
    }
    
    func getItemsCart() -> [Cart]? {
        guard let snapshot = dataSource?.snapshot() else { return nil }
        
        let items = snapshot.itemIdentifiers
        return items
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
extension CartViewController: CartCellDelegate {
    func didTappedRemoveButton(_ cell: UICollectionViewCell) {
        guard let indexPath = collectionView.indexPath(for: cell),
              let item = dataSource?.itemIdentifier(for: indexPath) else {
            fatalError("not founded indexPath or item in datasource")
        }
        
        self.removeItem(item: item)
        presenter.removeItem(item: item)
    }
}

// MARK: - CartViewDelegate
extension CartViewController: CartViewDelegate {
    func didTappedTotalButton() {
        print("pressed")
//        presenter.createOrder()
    }
}
