import Foundation

// MARK: - SizePickerPresenterProtocol
protocol SizePickerPresenterProtocol {
    init(view: SizePickerViewProtocol, item: Item, coordinator: SizePickerCoordinatorProtocol)
    func viewDidLoad()
    
    func getSizeRowsCount() -> Int
    func getSizeComponentCount() -> Int
    func getAvailableSizes() -> [Size]
    func selectSize(by index: Int) 
}

// MARK: - SizePickerPresenterProtocol Implementation
class SizePickerPresenter: SizePickerPresenterProtocol {
    weak var view: SizePickerViewProtocol?
    weak var coordinator: SizePickerCoordinatorProtocol?
    var item: Item
    
    required init(view: SizePickerViewProtocol, item: Item, coordinator: SizePickerCoordinatorProtocol) {
        self.view = view
        self.coordinator = coordinator
        self.item = item
    }
    
    func viewDidLoad() {
        view?.configure()
    }
    
    func getSizeComponentCount() -> Int {
        return 1
    }
    
    func getSizeRowsCount() -> Int {
        return item.sizes.count
    }
    
    func getAvailableSizes() -> [Size] {
        return item.sizes
    }
    
    func selectSize(by index: Int) {
        guard let itemId = item.id else {
            return
        }
        
        let selectedSize = item.sizes[index].size
        let selectedPrice = item.sizes[index].price
        
        let cartItem = Cart(itemId: itemId, selectedSize: selectedSize, selectedPrice: selectedPrice)
        coordinator?.hideSizePicker(with: cartItem)
    }
}
