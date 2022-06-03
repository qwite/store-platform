import Foundation

protocol ImagePickerViewProtocol {
}

protocol ImagePickerPresenterProtocol {
    init(coordinator: ImagePickerCoordinator, view: ImagePickerViewProtocol)
    func viewDidLoad()
    func didClosePicker(with imageData: Data)
}

class ImagePickerPresenter: ImagePickerPresenterProtocol {
    var coordinator: ImagePickerCoordinator
    var view: ImagePickerViewProtocol
    
    required init(coordinator: ImagePickerCoordinator, view: ImagePickerViewProtocol) {
        self.coordinator = coordinator
        self.view = view
    }
    
    func viewDidLoad() {}
    
    func didClosePicker(with imageData: Data) {
        coordinator.closePicker(with: imageData)
    }
}
