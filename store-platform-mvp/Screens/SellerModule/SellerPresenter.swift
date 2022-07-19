import Foundation
import FLCharts

// MARK: - SellerPresenterProtocol
protocol SellerPresenterProtocol {
    init (view: SellerViewProtocol, coordinator: SellerCoordinator, service: BrandServiceProtocol)
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

// MARK: - SellerPresenterProtocol Implementation
class SellerPresenter: SellerPresenterProtocol {
    weak var view: SellerViewProtocol?
    weak var coordinator: SellerCoordinator?
    var service: BrandServiceProtocol?
    
    required init(view: SellerViewProtocol, coordinator: SellerCoordinator, service: BrandServiceProtocol) {
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
        guard SettingsService.sharedInstance.brandName == nil,
        let userId = SettingsService.sharedInstance.userId else {
            return
        }
        
        service?.getBrandName(by: userId, completion: { result in
            switch result {
            case .success(let brandName):
                SettingsService.sharedInstance.brandName = brandName
            case .failure(let error):
                print(error)
            }
        })
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
    
    func getItemsFromBrand() {
        guard let userId = SettingsService.sharedInstance.userId else {
            return
        }
        
        service?.fetchItems(by: userId, completion: { [weak self] result in
            switch result {
            case .success(let items):
                self?.convertToItemViews(items: items, completion: { views in
                    self?.view?.insertSellerItems(items: views)
                })
                
            case .failure(_):
                self?.view?.insertEmptyItems()
            }
        })
    }
    
    func getDailyData() {
        guard let userId = SettingsService.sharedInstance.userId else {
            return
        }
        
        let currentMonth = Date.currentMonth
        
        service?.fetchMonthlyViews(by: userId, month: currentMonth, completion: { [weak self] result in
            switch result {
            case .success(let views):
                self?.view?.insertSellerViews(views: views)
            case .failure(let error):
                debugPrint(error)
                self?.view?.insertEmptySellerViews()
            }
        })
    }
    
    func getSales() {
        guard let userId = SettingsService.sharedInstance.userId else {
            return
        }
        
        service?.fetchSales(by: userId, completion: { [weak self] result in
            switch result {
            case .success(let items):
                let names = items.map({ $0.clothingName })
                let prices = items.compactMap( {$0.sizes!.first!.price} )
                let totalPrice = prices.reduce(0, +)
                
                guard let sales = self?.convertToSales(data: names),
                      let salesPrice = self?.convertToSalesPrice(data: prices) else {
                    fatalError()
                }
                                
                self?.view?.insertSellerSales(sales: sales)
                self?.view?.insertSellerSalesPrice(salesPrice: salesPrice)
                self?.view?.insertFinance(finance: Finance(totalPrice: totalPrice))
            case .failure(let error):
                debugPrint(error)
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
    
    func convertToItemViews(items: [Item], completion: @escaping ([Views]) -> ()){
        var itemViews: [Views] = []
        let currentMonth = Date.currentMonth
        for item in items {
            guard let itemId = item.id else { return }
            service?.fetchMonthlyViewsItem(by: itemId, month: currentMonth, completion: { result in
                switch result {
                case .success(let views):
                    let newViews = views.map({$0.amount})
                    let totalViews = newViews.reduce(0, +)
                    let value = Views(item: item, views: totalViews)
                    itemViews.append(value)
                case .failure(_):
                    let zeroViews = Views(item: item, views: 0)
                    itemViews.append(zeroViews)
                }
                
                if itemViews.count == items.count {
                    completion(itemViews.sorted(by: { $0.views > $1.views }))
                }
            })
        }
    }
    
    func convertToSalesPrice(data: [Int]) -> [SalesPrice] {
        var salesPrice: [SalesPrice] = []
        let currentMonth = Date.currentMonth
        data.forEach { value in
            let item = SalesPrice(month: currentMonth, price: value)
            salesPrice.append(item)
        }
        
        return salesPrice
    }
    
}
