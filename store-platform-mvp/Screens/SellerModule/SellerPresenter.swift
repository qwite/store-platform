import Foundation
import FLCharts

protocol SellerPresenterProtocol {
    init (view: SellerViewProtocol, coordinator: SellerCoordinator, service: UserServiceProtocol)
    func viewDidLoad()
    func viewWillAppear()
    
    func getItemsFromBrand()
    func getDailyData()
    func getSales()
    
    func prepareDailyData(data: [MonthlyViews]) -> [MultiPlotable]
    func prepareSalesPrice(data: [SalesPrice]) -> [MultiPlotable]
    func prepareSalesData(data: [Sales]) -> [FLPiePlotable]
    
    func showCreateAdScreen()
    func showMessagesList()
    func showOrders()
    
    func saveLocalBrand()
}

class SellerPresenter: SellerPresenterProtocol {
    weak var view: SellerViewProtocol?
    weak var coordinator: SellerCoordinator?
    var service: UserServiceProtocol?
    
    required init(view: SellerViewProtocol, coordinator: SellerCoordinator, service: UserServiceProtocol) {
        self.view = view
        self.coordinator = coordinator
        self.service = service
    }
    
    func viewWillAppear() {
        getItemsFromBrand()
    }
    
    func viewDidLoad() {
        view?.configureCollectionView()
        view?.configureDataSource()
        view?.configureViews()
        
        getDailyData()
        getSales()
        saveLocalBrand()
    }
    
    func saveLocalBrand() {
        if SettingsService.sharedInstance.brandName == nil {
            service?.getBrandName(completion: { result in
                switch result {
                case .success(let brandName):
                    SettingsService.sharedInstance.brandName = brandName
                    print(SettingsService.sharedInstance.brandName)
                case .failure(let error):
                    fatalError()
                }
            })
        }
    }
    
    func showMessagesList() {
        coordinator?.showListMessages()
    }
    
    func showCreateAdScreen() {
        coordinator?.showCreateAdScreen()
    }
    
    func showOrders() {
        coordinator?.showSellerOrders()
    }
    
    // Item + views count
    func getItemsFromBrand() {
        debugPrint("[get items from brand]")
        service?.getItemsFromBrand(completion: { [weak self] result in
            guard let items = try? result.get() else {
                self?.view?.insertEmptyItems(); return
            }
            
            self?.convertToItemViews(items: items, completion: { itemViews in
                self?.view?.insertSellerItems(items: itemViews)
            })
            
        })
    }
    
    func getDailyData() {
        service?.getItemViewsBrand(completion: { [weak self] result in
            switch result {
            case .success(let views):
//                debugPrint(views)
                self?.view?.insertSellerViews(views: views)
            case .failure(let error):
//                fatalError("\(error)")
                self?.view?.insertEmptySellerViews()
            }
        })
    }
    
    func getSales() {
        service?.getItemSalesFromBrand(completion: { [weak self] result in
            print("fetching sales...")
            switch result {
            case .success(let items):
//                print(items)
                let names = items.map({ $0.clothingName })
                let prices = items.map( {$0.sizes!.first!.price!} )
                let totalPrice = prices.reduce(0, +)
                
                guard let sales = self?.convertToSales(data: names),
                      let salesPrice = self?.convertToSalesPrice(data: prices) else {
                    fatalError()
                }
                
                debugPrint(salesPrice)
                
                self?.view?.insertSellerSales(sales: sales)
                self?.view?.insertSellerSalesPrice(salesPrice: salesPrice)
                self?.view?.insertFinance(finance: Finance(totalPrice: totalPrice))
                
            case .failure(let error):
                self?.view?.insertEmptyFinance()
                print("sales not found!")

            }
        })
    }
    
    func prepareDailyData(data: [MonthlyViews]) -> [MultiPlotable] {
        var graphData: [MultiPlotable] = []
        
        let filtered = data.reduce(into: [String: Int]()) { partialResult, views in
            partialResult["\(views.day)", default: 0] += views.amount
        }
        
        for value in filtered {
            let item = MultiPlotable(name: value.key, values: [value.value.cgFloat])
            graphData.append(item)
        }
        
        return graphData.sorted(by: {Int($0.name)! < Int($1.name)!})
    }
    
    func prepareSalesPrice(data: [SalesPrice]) -> [MultiPlotable] {
        var graphData: [MultiPlotable] = []
        
        for value in data {
            let item = MultiPlotable(name: value.month, values: [value.price.cgFloat])
            graphData.append(item)
        }
        
        debugPrint("graphData: \(graphData)")
        
        //        return graphData.sorted(by: {$0.maxValue > $1.maxValue})

        return graphData.sorted(by: {$0.maxValue < $1.maxValue})
    }
    
    func prepareSalesData(data: [Sales]) -> [FLPiePlotable] {
        var graphData: [FLPiePlotable] = []
        let colors: [FLColor] = [.lightBlue, .blue, .darkBlue, .seaBlue]
        
        for (index, value) in data.enumerated() {
            let key = Key(key: value.item, color: colors[index])
            let item = FLPiePlotable(value: value.count.cgFloat, key: key)
            graphData.append(item)
        }
        
        return graphData.sorted(by: {$0.value < $1.value})
    }
    
    func convertToSales(data: [String]) -> [Sales] {
        var dictionary: [String: Int] = [:]
        var sales: [Sales] = []
        data.forEach { value in
            dictionary[value] = (dictionary[value] ?? 0) + 1
        }
        
        dictionary.forEach { dict in
            let item = Sales(item: dict.key, count: dict.value)
            sales.append(item)
        }
        
        return sales
    }
    
    // FIXME: rewrite
    func convertToItemViews(items: [Item], completion: @escaping ([ItemViews]) -> ()){
        var itemViews: [ItemViews] = []
        for item in items {
            FirestoreService.sharedInstance.getViewsAmountFromItem(itemId: item.id!) { result in
                if let views = try? result.get() {
                    let newViews = views.map({$0.amount})
                    let totalViews = newViews.reduce(0, +)
                    let value = ItemViews(item: item, views: totalViews)
                    itemViews.append(value)
                } else {
                    let zeroViews = ItemViews(item: item, views: 0)
                    itemViews.append(zeroViews)
                }
                
                if itemViews.count == items.count {
                    completion(itemViews.sorted(by: { $0.views > $1.views }))
                }
            }
        }
    }
    
    func convertToSalesPrice(data: [Int]) -> [SalesPrice] {
        var salesPrice: [SalesPrice] = []
        
        data.forEach { value in
            let item = SalesPrice(month: "Jun", price: value)
            salesPrice.append(item)
        }
        
        return salesPrice
    }
    
}
