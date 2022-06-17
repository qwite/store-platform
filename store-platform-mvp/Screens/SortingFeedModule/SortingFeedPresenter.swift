import Foundation

protocol SortingFeedPresenterDelegate: AnyObject {
    func insertPopularItems(items: [ItemViews])
    func insertSortedItems(items: [Item])
}

protocol SortingFeedPresenterProtocol {
    init(view: SortingFeedViewProtocol)
    func viewDidLoad()
    var delegate: SortingFeedPresenterDelegate? { get set }
    
    func buttonWasPressed(with type: RadioButton.RadioButtonType)
    
    func getPopularItems()
    func showResults()
    func preparePopularItems(items: [Int : [String : Any]], completion: @escaping (([ItemViews]) -> ()))
}

class SortingFeedPresenter: SortingFeedPresenterProtocol {
    var view: SortingFeedViewProtocol?
    weak var delegate: SortingFeedPresenterDelegate?
    var selectedType: RadioButton.RadioButtonType?
    
    required init(view: SortingFeedViewProtocol) {
        self.view = view
    }
    
    func viewDidLoad() {
        view?.configureViews()
        view?.configureButtons()
//        getPopularItems()
    }
    
    func buttonWasPressed(with type: RadioButton.RadioButtonType) {
        self.selectedType = type
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
    
    func getPopularItems() {
        FirestoreService.sharedInstance.getPopularItems { [weak self] result in
            switch result {
            case .success(let items):
                self?.preparePopularItems(items: items, completion: { itemsViews in
                    self?.delegate?.insertPopularItems(items: itemsViews)
                })
            case .failure(let error):
                fatalError("\(error)")
            }
        }
    }
    
    func getItemsByPrice(sorting: Item.Sorting) {
        FirestoreService.sharedInstance.getAllItems(sorted: sorting) { [weak self] result in
            switch result {
            case .success(let items):
                self?.delegate?.insertSortedItems(items: items)
            case .failure(let error):
                fatalError("\(error)")
            }
        }
    }
    
    func preparePopularItems(items: [Int : [String : Any]], completion: @escaping (([ItemViews]) -> ())) {
        var itemViews: [ItemViews] = []
        
        for value in items.values {
            guard let views = value["views"] as? [MonthlyViews],
                  let item = value["item"] as? Item else {
                return
            }
            
            let summaryViews = views.reduce(0) { partialResult, monthly in
                monthly.amount + partialResult
            }
            
            itemViews.append(ItemViews(item: item, views: summaryViews))
        }
        
        completion(itemViews)
    }
}
