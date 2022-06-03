import Foundation

protocol PickSizePresenterProtocol {
    init(view: PickSizeViewProtocol, sizes: [Size], coordinator: PickSizeCoordinatorProtocol)
    func viewDidLoad()
    func getSizeRowsCount() -> Int
    func getSizeComponentCount() -> Int
    func getAvailableSizes() -> [Size]
    func selectSize(by index: Int) 
}

class PickSizePresenter: PickSizePresenterProtocol {
    weak var view: PickSizeViewProtocol?
    weak var coordinator: PickSizeCoordinatorProtocol?
    var sizes: [Size]
    
    required init(view: PickSizeViewProtocol, sizes: [Size], coordinator: PickSizeCoordinatorProtocol) {
        self.view = view
        self.coordinator = coordinator
        self.sizes = sizes
    }
    
    func viewDidLoad() {
        view?.configure()
    }
    
    func getSizeComponentCount() -> Int {
        return 1
    }
    
    func getSizeRowsCount() -> Int {
        return sizes.count
    }
    
    func getAvailableSizes() -> [Size] {
        return sizes
    }
    
    func selectSize(by index: Int) {
        let selectedSize = sizes[index]
     
        coordinator?.hideSizePicker(with: selectedSize)
    }
}
