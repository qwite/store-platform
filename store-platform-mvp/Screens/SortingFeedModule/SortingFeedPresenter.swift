import Foundation

// MARK: - SortingFeedPresenterDelegate
protocol SortingFeedPresenterDelegate: AnyObject {
    func insertPopularItems(items: [Item])
    func insertSortedItems(items: [Item])
    func resetSettings()
}

// MARK: - SortingFeedPresenterProtocol
protocol SortingFeedPresenterProtocol: AvailableParameterPresenterDelegate {
    init(view: SortingFeedViewProtocol, coordinator: FeedCoordinator, service: FeedServiceProtocol)
    func viewDidLoad()
    var delegate: SortingFeedPresenterDelegate? { get set }
    
    func buttonWasPressed(with type: RadioButton.RadioButtonType)
    
    func showColorParameters()
    func showSizeParameters()
    func setSelectedPrice(price: [Float])
    
    func getPopularItems()
    func showResults()
    func applyFilters(items: [Item]) -> [Item]
    func preparePopularItems(items: [Int : [String : Any]], completion: @escaping (([Views]) -> ()))
    func clearSortSettings()
    func closeSortingWindow()
}

// MARK: SortingFeedPresenter Implementation
class SortingFeedPresenter: SortingFeedPresenterProtocol {
    
    var view: SortingFeedViewProtocol?
    weak var delegate: SortingFeedPresenterDelegate?
    weak var coordinator: FeedCoordinator?
    var service: FeedServiceProtocol?
    
    var selectedType: RadioButton.RadioButtonType?
    var selectedColors: [String]? {
        didSet { self.view?.updateColors(colors: selectedColors!) }
    }
    
    var selectedSizes: [String]? {
        didSet { self.view?.updateSizes(sizes: selectedSizes!) }
    }
    
    var selectedPrice: [Float]? {
        didSet { self.view?.updatePrice(price: selectedPrice!) }
    }
    
    required init(view: SortingFeedViewProtocol, coordinator: FeedCoordinator, service: FeedServiceProtocol) {
        self.view = view
        self.coordinator = coordinator
        self.service = service
    }
    
    func viewDidLoad() {
        view?.configureViews()
        view?.configureButtons()
    }
    
    func buttonWasPressed(with type: RadioButton.RadioButtonType) {
        self.selectedType = type
    }
    
    func showColorParameters() {
        coordinator?.showColorParameters()
    }
    
    func showSizeParameters() {
        coordinator?.showSizeParameters()
    }
    
    func setSelectedPrice(price: [Float]) {
        self.selectedPrice = price
        print(selectedPrice!)
    }
    
    func clearSortSettings() {
        delegate?.resetSettings()
        self.closeSortingWindow()
    }
    
    func closeSortingWindow() {
        coordinator?.hideSortingFeed()
    }
    
    func showResults() {
        guard let selectedType = selectedType else {
            view?.showErrorAlert(); return
        }
        
        switch selectedType {
        case .newItems:
            break
        case .popularItems:
            self.getPopularItems()
        case .byIncreasingPrice:
            self.getItemsByPrice(sorting: .byIncreasePrice)
        case .byDecreasingPrice:
            self.getItemsByPrice(sorting: .byDecreasePrice)
        }
    }
    
    func applyFilters(items: [Item]) -> [Item] {
        var filteredItems: [Item] = items
        
        // price from ; price up to
        if let selectedPrice = self.selectedPrice {
            filteredItems = filteredItems.filter({ item in
                let priceFrom = Int(selectedPrice[0])
                let priceUpTo = Int(selectedPrice[1])
                guard let firstSizePrice = item.sizes?.first?.price else { return false }
                
                return (firstSizePrice >= priceFrom) && (firstSizePrice <= priceUpTo)
            })
        }
        
        if let selectedColors = selectedColors {
            filteredItems = filteredItems.filter({ item in
                selectedColors.contains(where: { $0 == item.color} )
            })
        }
        
        
        // item object has sizes: [Size]
        // size string is size[0].size
        // selected sizes has array of string sizes ["XS", "S", .. etc]
        if let selectedSizes = selectedSizes {
            filteredItems = filteredItems.filter({ item in
                guard let sizes = item.sizes else { fatalError() }
                var result: Bool?
                for size in sizes {
                    // selectedSizes = ["XS", "M", "L"]
                    // sizes = ["M"]
                    if selectedSizes.contains(where: { $0 == size.size}) {
                        result = true
                        break
                    }
                }
                
                guard result != nil else {
                    return false
                }
                
                return true
            })
        }
        
        return filteredItems
    }
    
    // MARK: - refactor
    func getPopularItems() {
        service?.fetchPopularItems(completion: { [weak self] result in
            switch result {
            case .success(let items):
                self?.preparePopularItems(items: items, completion: { itemsViews in
                    let sortedItems = itemsViews.sorted(by: { $0.views > $1.views })
                    let resultItems = sortedItems.map({ $0.item })
                    guard let filteredItems = self?.applyFilters(items: resultItems) else { return }
                    self?.delegate?.insertPopularItems(items: filteredItems)
                    self?.closeSortingWindow()
                })
                
            case .failure(let error):
                fatalError("\(error)")
            }
        })
    }
    
    func getItemsByPrice(sorting: Item.Sorting) {
        service?.fetchAllItems(by: sorting) { [weak self] result in
            switch result {
            case .success(let items):
                guard let filteredItems = self?.applyFilters(items: items) else { return }
                self?.delegate?.insertSortedItems(items: filteredItems)
                self?.closeSortingWindow()
            case .failure(let error):
                fatalError("\(error)")
            }
        }
    }
    
    func preparePopularItems(items: [Int : [String : Any]], completion: @escaping (([Views]) -> ())) {
        var itemViews: [Views] = []
        
        for value in items.values {
            guard let views = value["views"] as? [MonthlyViews],
                  let item = value["item"] as? Item else {
                return
            }
            
            let summaryViews = views.reduce(0) { partialResult, monthly in
                monthly.amount + partialResult
            }
            
            itemViews.append(Views(item: item, views: summaryViews))
        }
        
        completion(itemViews)
    }
}

// MARK: - AvailableParameterPresenterDelegate
extension SortingFeedPresenter: AvailableParameterPresenterDelegate {
    func insertSelectedParameters(_ selectedItems: [Parameter]) {
        guard let firstItem = selectedItems.first else { print("items not found "); return }
        switch firstItem.type {
        case .color:
            self.selectedColors = selectedItems.map({ $0.option })
        case .size:
            self.selectedSizes = selectedItems.map({ $0.option })
        }
    }
}
