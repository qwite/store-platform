import Foundation

// MARK: - CreateSizeViewPresenterProtocol
protocol CreateSizeViewPresenterProtocol: AnyObject {
    init(view: CreateSizeViewProtocol, coordinator: CreateAdCoordinator, model: Size?)
    func viewDidLoad()
    
    func addSizeItem(size: Size)
    func editSizeItem(size: Size)
}

// MARK: - CreateSizeViewPresenterProtocol Implementation
class CreateSizePresenter: CreateSizeViewPresenterProtocol {
    weak var view: CreateSizeViewProtocol?
    weak var coordinator: CreateAdCoordinator?
    
    var model: Size?
    var editMode: Bool?
    
    required init(view: CreateSizeViewProtocol, coordinator: CreateAdCoordinator, model: Size?) {
        self.view = view
        self.coordinator = coordinator
        self.model = model
    }
    
    func viewDidLoad() {
        view?.configure()
        view?.setSegmentedControlSource(items: Size.AvailableSizes.allCases.map({ $0.rawValue.uppercased() }))
        
        guard model == nil else {
            view?.loadSavedValues(item: model!)
            self.editMode = true
            return
        }
    }
    
    func addSizeItem(size: Size) {
        coordinator?.addNewSizeItem(size)
    }
    
    func editSizeItem(size: Size) {
        coordinator?.editSizeItem(size)
    }
}
