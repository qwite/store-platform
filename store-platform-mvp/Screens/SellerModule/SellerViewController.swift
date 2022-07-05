import UIKit
import FLCharts

protocol SellerViewProtocol: AnyObject {
    func configureCollectionView()
    func configureDataSource()
    func configureViews()
    
    func insertSellerItems(items: [ItemViews])
    func insertSellerViews(views: [MonthlyViews])
    func insertSellerSales(sales: [Sales])
    func insertSellerSalesPrice(salesPrice: [SalesPrice])
    func insertFinance(finance: Finance)
    
    func insertEmptyItems()
    func insertEmptySellerViews()
    func insertEmptyFinance()
}

class SellerViewController: UIViewController {
    var presenter: SellerPresenterProtocol!
    var sellerView = SellerView()
    var collectionView: UICollectionView! = nil
    
    var dataSource: UICollectionViewDiffableDataSource<SellerView.Section, AnyHashable>?
    typealias DataSource = UICollectionViewDiffableDataSource<SellerView.Section, AnyHashable>
    // MARK: - Lifecycle
    
    override func loadView() {
        view = sellerView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        presenter.viewWillAppear()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewDidLoad()
        
        configureNavigationRightButtons()
        
        // TODO: fix
        self.navigationController?.navigationBar.topItem?.title = "Мои товары"
    }
}

extension SellerViewController: SellerViewProtocol {
    func configureCollectionView() {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: sellerView.generateLayout())
        collectionView.register(SellerItemCell.self, forCellWithReuseIdentifier: SellerItemCell.reuseId)
        collectionView.register(AddItemButtonView.self, forSupplementaryViewOfKind: SellerView.SupplementaryKinds.addItemButton.rawValue, withReuseIdentifier: AddItemButtonView.reuseId)
        collectionView.register(SellerHeaderView.self, forSupplementaryViewOfKind: SellerView.SupplementaryKinds.header.rawValue, withReuseIdentifier: SellerHeaderView.reuseId)
        collectionView.register(SellerChartCell.self, forCellWithReuseIdentifier: SellerChartCell.reuseId)
        collectionView.register(SellerFinanceCell.self, forCellWithReuseIdentifier: SellerFinanceCell.reuseId)

        self.collectionView = collectionView
    }
    
    func configureDataSource() {
        self.dataSource = DataSource(collectionView: collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            let section = SellerView.Section.allCases[indexPath.section]
            switch section {
            case .items:
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SellerItemCell.reuseId, for: indexPath) as? SellerItemCell else {
                    fatalError("dequeueReusableCell error for \(SellerItemCell.reuseId)")
                }
                
                guard let item = itemIdentifier as? ItemViews else {
                    cell.itemsNotExist(); return cell
                }
                
                cell.configure(itemViews: item)
                return cell
            case .stats:
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SellerChartCell.reuseId, for: indexPath) as? SellerChartCell else { fatalError() }
                
                if let stat = itemIdentifier as? [MonthlyViews] {
                    let graphData = self.presenter.prepareDailyData(data: stat)
                    cell.createDailyChart(data: graphData)
                    return cell
                }
                
                if let sales = itemIdentifier as? [Sales] {
                    let graphData = self.presenter.prepareSalesData(data: sales)
                    cell.createSalesChart(data: graphData)
                    return cell
                }
                
                if let salesPrice = itemIdentifier as? [SalesPrice] {
                    let graphData = self.presenter.prepareSalesPrice(data: salesPrice)
                    cell.createSalesLineChart(data: graphData)
                    return cell
                }
                
                cell.statNotExist()
                return cell
            case .finance:
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SellerFinanceCell.reuseId, for: indexPath) as? SellerFinanceCell else { fatalError() }
                
                guard let item = itemIdentifier as? Finance else {
                    cell.itemsNotExist(); return cell
                }
                
                cell.configure(totalPrice: item.totalPrice)
                return cell
            }
        })
        
        dataSource?.supplementaryViewProvider = { (collectionView: UICollectionView, kind: String, indexPath: IndexPath) -> UICollectionReusableView? in
            switch kind {
            case "section-header-button-kind":
                guard let supplementaryView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: AddItemButtonView.reuseId, for: indexPath) as? AddItemButtonView else {
                    fatalError("dequeueReusableSupplementaryView error for \(AddItemButtonView.reuseId)")
                }
                supplementaryView.delegate = self
                supplementaryView.configureViews()
                
                return supplementaryView
            case "section-header-label-kind":
                guard let supplementaryView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: SellerHeaderView.reuseId, for: indexPath) as? SellerHeaderView else {
                    fatalError()
                }
                
                supplementaryView.label.text = SellerView.Section.allCases[indexPath.section].rawValue
                supplementaryView.configureViews()
                return supplementaryView
            default:
                return nil
            }
        }
        
        let snapshot = snapshotForCurrentState()
        dataSource?.apply(snapshot)
    }
    
    func snapshotForCurrentState() -> NSDiffableDataSourceSnapshot<SellerView.Section, AnyHashable> {
        var snapshot = NSDiffableDataSourceSnapshot<SellerView.Section, AnyHashable>()
        snapshot.appendSections([.items])
        snapshot.appendSections([.stats])
        snapshot.appendSections([.finance])
        return snapshot
    }
    
    func configureViews() {
        sellerView.backgroundColor = .white
        
        view.addSubview(collectionView)
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.width.equalTo(view.snp.width)
            make.bottom.equalTo(view.snp.bottom)
        }
    }
    
    func insertEmptyItems() {
        var snapshot = dataSource?.snapshot()
        let hint = AnyHashable(101)
        snapshot?.appendItems([hint], toSection: .items)
        dataSource?.apply(snapshot!)
    }
    
    func insertSellerItems(items: [ItemViews]) {
        var snapshot = dataSource?.snapshot()
        snapshot?.deleteItems([AnyHashable(101)])
        snapshot?.itemIdentifiers.forEach({ if $0 is ItemViews { snapshot?.deleteItems([$0])}})
        snapshot?.appendItems(items, toSection: .items)
        dataSource?.apply(snapshot!)
    }
    
    func insertEmptySellerViews() {
        var snapshot = dataSource?.snapshot()
        snapshot?.appendItems([AnyHashable(202)], toSection: .stats)
        dataSource?.apply(snapshot!)
    }
    
    func insertSellerViews(views: [MonthlyViews]) {
        var snapshot = dataSource?.snapshot()
        snapshot?.deleteItems([AnyHashable(202)])
        snapshot?.appendItems([views], toSection: .stats)
        dataSource?.apply(snapshot!)
    }
    
    func insertSellerSales(sales: [Sales]) {
        var snapshot = dataSource?.snapshot()
        snapshot?.appendItems([sales], toSection: .stats)
        dataSource?.apply(snapshot!)
    }
    
    func insertSellerSalesPrice(salesPrice: [SalesPrice]) {
        var snapshot = dataSource?.snapshot()
        snapshot?.appendItems([salesPrice], toSection: .stats)
        dataSource?.apply(snapshot!)
    }
    
    func insertEmptyFinance() {
        var snapshot = dataSource?.snapshot()
        snapshot?.appendItems([AnyHashable(303)], toSection: .finance)
        dataSource?.apply(snapshot!)
    }
    
    func insertFinance(finance: Finance) {
        var snapshot = dataSource?.snapshot()
        snapshot?.appendItems([finance], toSection: .finance)
        dataSource?.apply(snapshot!)
    }
}

extension SellerViewController: AddItemButtonViewDelegate {
    func didTappedAddButton() {
        presenter.showCreateAdScreen()
    }
}


// MARK: UINavigationBar Button
extension SellerViewController {
    func configureNavigationRightButtons() {
        let messengerImage = UIImage(named: "messenger_seller")?.withTintColor(.black, renderingMode: .alwaysOriginal)
        let messengerItem = UIBarButtonItem(image: messengerImage,
                                            style: .plain,
                                            target: self,
                                            action: #selector(messengerItemAction))
        
        let ordersImage = UIImage(systemName: "doc.plaintext")?.withTintColor(.black, renderingMode: .alwaysOriginal)
        let ordersItem = UIBarButtonItem(image: ordersImage, style: .plain, target: self, action: #selector(ordersItemAction))
        
        self.navigationItem.rightBarButtonItems = [ordersItem, messengerItem]
    }
    
    @objc func messengerItemAction() {
        presenter.showMessagesList()
    }
    
    @objc func ordersItemAction() {
        presenter.showOrders()
    }
}


