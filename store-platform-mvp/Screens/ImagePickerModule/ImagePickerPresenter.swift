import Foundation

// MARK: - ImagePickerPresenterDelegate
protocol ImagePickerPresenterDelegate: AnyObject {
    func didCloseImagePicker(with imageData: Data)
}

// MARK: - ImagePickerPresenterProtocol
protocol ImagePickerPresenterProtocol {
    init(coordinator: ImagePickerCoordinator, view: ImagePickerViewProtocol)
    func viewDidLoad()
    func didClosePicker(with imageData: Data)
}

// MARK: - ImagePickerPresenterProtocol Implementation
class ImagePickerPresenter: ImagePickerPresenterProtocol {
    weak var coordinator: ImagePickerCoordinator?
    weak var view: ImagePickerViewProtocol?
    weak var delegate: ImagePickerPresenterDelegate?
    
    required init(coordinator: ImagePickerCoordinator, view: ImagePickerViewProtocol) {
        self.coordinator = coordinator
        self.view = view
    }
    
    public func viewDidLoad() {}
    
    public func didClosePicker(with imageData: Data) {
        delegate?.didCloseImagePicker(with: imageData)
        coordinator?.closePicker()
    }
}
