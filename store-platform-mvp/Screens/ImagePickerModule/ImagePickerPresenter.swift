import Foundation

protocol ImagePickerPresenterDelegate: AnyObject {
    func didCloseImagePicker(with imageData: Data)
}

protocol ImagePickerPresenterProtocol {
    init(coordinator: ImagePickerCoordinator, view: ImagePickerViewProtocol)
    func viewDidLoad()
    func didClosePicker(with imageData: Data)
}

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
