import Foundation

protocol PickSizePresenterProtocol {
    init(view: PickSizeViewProtocol, item: Item, coordinator: PickSizeCoordinatorProtocol)
    func viewDidLoad()
    func getSizeRowsCount() -> Int
    func getSizeComponentCount() -> Int
    func getAvailableSizes() -> [Size]
    func selectSize(by index: Int) 
}

class PickSizePresenter: PickSizePresenterProtocol {
    weak var view: PickSizeViewProtocol?
    weak var coordinator: PickSizeCoordinatorProtocol?
    var item: Item
    
    required init(view: PickSizeViewProtocol, item: Item, coordinator: PickSizeCoordinatorProtocol) {
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
        
        // TODO: remove itemId and rewrite class mb delete this.
        let cartItem = CartItem(item: item, itemId: itemId, selectedSize: selectedSize, selectedPrice: selectedPrice)
        coordinator?.hideSizePicker(with: cartItem)
    }
}
