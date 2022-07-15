import Foundation

// MARK: - PickSizePresenterProtocol
protocol SizePickerPresenterProtocol {
    init(view: SizePickerViewProtocol, item: Item, coordinator: SizePickerCoordinatorProtocol)
    func viewDidLoad()
    
    func getSizeRowsCount() -> Int
    func getSizeComponentCount() -> Int
    func getAvailableSizes() -> [Size]
    func selectSize(by index: Int) 
}

// MARK: - PickSizePresenterProtocol Implementation
class PickSizePresenter: SizePickerPresenterProtocol {
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
        guard let sizes = item.sizes else {
            return 0
        }
        
        return sizes.count
    }
    
    func getAvailableSizes() -> [Size] {
        guard let sizes = item.sizes else {
            fatalError()
        }
        
        return sizes
    }
    
    func selectSize(by index: Int) {
        guard let sizes = item.sizes,
              let itemId = item.id,
              let selectedSize = sizes[index].size,
              let selectedPrice = sizes[index].price else {
            return
        }
                
        let cartItem = Cart(itemId: itemId, selectedSize: selectedSize, selectedPrice: selectedPrice)
        coordinator?.hideSizePicker(with: cartItem)
    }
}
