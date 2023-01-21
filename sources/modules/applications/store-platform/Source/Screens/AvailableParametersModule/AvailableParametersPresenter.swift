import Foundation

// MARK: - AvailableParameterPresenterDelegate
protocol AvailableParameterPresenterDelegate: AnyObject {
    func insertSelectedParameters(_ selectedItems: [Parameter])
}

// MARK: - AvailableParametersPresenterProtocol
protocol AvailableParametersPresenterProtocol {
    init(view: AvailableParametersView, delegate: AvailableParameterPresenterDelegate, type: Parameter.ParameterType)
    func viewDidLoad()
    
    func shareSelectedItems(selectedItems: [Parameter])
}

// MARK: - AvailableParametersPresenterProtocol Implementation
class AvailableParametersPresenter: AvailableParametersPresenterProtocol {
    weak var view: AvailableParametersView?
    weak var delegate: AvailableParameterPresenterDelegate?
    var type: Parameter.ParameterType
    
    required init(view: AvailableParametersView, delegate: AvailableParameterPresenterDelegate, type: Parameter.ParameterType) {
        self.view = view
        self.delegate = delegate
        self.type = type
    }
    
    let colors = ["Черный", "Белый", "Красный", "Синий", "Зеленый", "Желтый", "Оранжевый", "Фиолетовый", "Бежевый", "Хаки", "Разноцветный"]
    let sizes = ["XXS", "XS", "S", "M", "L", "XL", "XXL"]
    
    func viewDidLoad() {
        view?.configureTableView()
        view?.configureDataSource()
        view?.configureViews()
        
        switch type {
        case .color:
            self.insertColors()
        case .size:
            self.insertSizes()
        }
    }
    
    func insertColors() {
        let colorsParameter: [Parameter] = colors.map({ Parameter(option: $0, type: .color, isSelected: true) })
        view?.updateDataSource(items: colorsParameter)
    }
    
    func insertSizes() {
        let sizesParameter: [Parameter] = sizes.map({ Parameter(option: $0, type: .size, isSelected: true)})
        view?.updateDataSource(items: sizesParameter)
    }
    
    func shareSelectedItems(selectedItems: [Parameter]) {
        delegate?.insertSelectedParameters(selectedItems)
    }
}
