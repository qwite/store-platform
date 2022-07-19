import Foundation

protocol CreateSizeViewPresenterProtocol: AnyObject {
    init(view: CreateSizeViewProtocol, coordinator: CreateAdCoordinator, model: Size?)
    func viewDidLoad()
    func addSizeItem(sizeIndex: Int, price: Int?, amount: Int?)
    func editSizeItem(sizeIndex: Int, price: Int?, amount: Int?)
    func checkModel()
}

class CreateSizePresenter: CreateSizeViewPresenterProtocol {
    weak var view: CreateSizeViewProtocol?
    let coordinator: CreateAdCoordinator
    let model: Size?
    var editMode: Bool?
    
    required init(view: CreateSizeViewProtocol, coordinator: CreateAdCoordinator, model: Size?) {
        self.view = view
        self.coordinator = coordinator
        self.model = model
        self.editMode = nil
    }
    
    func viewDidLoad() {
        view?.configure()
        view?.setSegmentedControlSource(items: Size.AvailableSizes.allCases.map({$0.rawValue}))
        checkModel()
    }
    
    func checkModel() {
        guard let model = model else {
            return
        }
        
        self.editMode = true
        view?.loadSavedValues(item: model)
    }
    
    func addSizeItem(sizeIndex: Int, price: Int?, amount: Int?) {
        let item = Size(size: Size.AvailableSizes.allCases[sizeIndex].rawValue, price: price, amount: amount)
        coordinator.addNewSizeItem(item)
    }
    
    func editSizeItem(sizeIndex: Int, price: Int?, amount: Int?) {
        let item = Size(size: Size.AvailableSizes.allCases[sizeIndex].rawValue, price: price, amount: amount)
        coordinator.editSizeItem(item)
    }
}
