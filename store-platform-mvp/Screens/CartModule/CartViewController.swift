import UIKit

protocol CartViewProtocol: AnyObject {
    func configureCollectionView()
    func configureDataSource()
    func configureViews()
}

class CartViewController: UIViewController {
    var cartView = CartView()
    var presenter: CartPresenter!
    var collectionView: UICollectionView! = nil
    var dataSource: UICollectionViewDiffableDataSource<CartView.Section, Item>?
    typealias DataSource = UICollectionViewDiffableDataSource<CartView.Section, Item>
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
        collectionView.register(CartItem.self, forCellWithReuseIdentifier: CartItem.reuseId)
        self.collectionView = collectionView
    }
    
    func configureDataSource() {
        dataSource = DataSource(collectionView: self.collectionView, cellProvider: { (collectionView, indexPath, itemIdentifier) -> UICollectionViewCell in
            let section = CartView.Section.allCases[indexPath.section]
            switch section {
            case .cart:
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CartItem.reuseId, for: indexPath) as? CartItem else {
                    fatalError("dequeue error")
                }
                
                let item = itemIdentifier
                
                cell.configure(item: item)
                cell.layer.borderWidth = 1.0
                return cell
            }
        })
        
        let snapshot = snapshotForCurrentState()
        dataSource?.apply(snapshot)
    }
    
    func snapshotForCurrentState() -> NSDiffableDataSourceSnapshot<CartView.Section, Item> {
        var snapshot = NSDiffableDataSourceSnapshot<CartView.Section, Item>()
        let testSize = [Size(size: "S", price: 1337, amount: 3)]
        let item = Item(brandName: "Amek", clothingName: "tshirt", description: "adsdas", category: "asdsasd", color: "adsds", sizes: testSize)
        let item1 = Item(brandName: "Amek", clothingName: "hoodie", description: "sdasda", category: "", color: "", sizes: testSize)
        snapshot.appendSections([.cart])
        snapshot.appendItems([item, item1])
        return snapshot
    }
}
