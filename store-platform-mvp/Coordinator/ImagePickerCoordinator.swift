import UIKit

class ImagePickerCoordinator: Coordinator {
    var navigationController: UINavigationController
    var factory: Factory
    var childCoordinator = [Coordinator]()
    var delegate: CreateAdCoordinatorProtocol?
    
    func start() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            self.navigationController.present(sheetAlert(), animated: true, completion: nil)
        } else {
            showPicker(with: .photoLibrary)
        }
    }
    
    required init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
        factory = DependencyFactory()
    }
    
    func showPicker(with source: UIImagePickerController.SourceType) {
        let module = factory.buildImagePickerModule(coordinator: self)
        module.sourceType = source
        module.allowsEditing = false
        self.navigationController.present(module, animated: true)
    }
    
    func closePicker(with imageData: Data) {
        delegate?.didSelectImage(image: imageData)
        self.navigationController.dismiss(animated: true, completion: nil)
    }
    
    func sheetAlert() -> UIAlertController {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "Сделать снимок", style: .default) { _ in
            self.showPicker(with: .camera)
        }
        alert.addAction(cameraAction)
        let libraryAction = UIAlertAction(title: "Выбрать из галереи", style: .default) { _ in
            self.showPicker(with: .photoLibrary)
        }
        alert.addAction(libraryAction)
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
        alert.addAction(cancelAction)
        return alert
    }
}
