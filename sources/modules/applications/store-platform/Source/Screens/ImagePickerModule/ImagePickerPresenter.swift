import Foundation

// MARK: - ImagePickerDelegate
protocol ImagePickerDelegate: AnyObject {
    func didImageAdded(image: Data)
}

// MARK: - ImagePickerPresenterProtocol
protocol ImagePickerPresenterProtocol {
    init(coordinator: ImagePickerCoordinator, view: ImagePickerViewProtocol)
    func viewDidLoad()
    func finish()
    
    func didClosePicker(with imageData: Data)
}

// MARK: - ImagePickerPresenterProtocol Implementation
class ImagePickerPresenter: ImagePickerPresenterProtocol {
    weak var coordinator: ImagePickerCoordinator?
    weak var view: ImagePickerViewProtocol?
    
    required init(coordinator: ImagePickerCoordinator, view: ImagePickerViewProtocol) {
        self.coordinator = coordinator
        self.view = view
    }
    
    public func viewDidLoad() {
        view?.configure()
    }
    
    public func didClosePicker(with imageData: Data) {
        coordinator?.closePicker(with: imageData)
    }
    
    public func finish() {
        coordinator?.finishFlow?(nil)
    }
}
