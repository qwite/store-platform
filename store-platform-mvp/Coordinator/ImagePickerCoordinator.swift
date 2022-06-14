import UIKit

protocol ImagePickerCoordinatorDelegate: AnyObject {
    func didSelectImage(imageData: Data)
}

class ImagePickerCoordinator: Coordinator {
    var navigationController: UINavigationController
    var factory: Factory?
    var finish: (() -> ())?
    
    weak var delegate: ImagePickerPresenterDelegate?
    
    func start() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            self.navigationController.present(sheetAlert(), animated: true, completion: nil)
        } else {
            showPicker(with: .photoLibrary)
        }
    }
    
    required init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.factory = DependencyFactory()
    }
    
    func showPicker(with source: UIImagePickerController.SourceType) {
        guard let delegate = delegate,
              let module = factory?.buildImagePickerModule(coordinator: self, delegate: delegate) else {
            return
        }
        
        module.sourceType = source
        module.allowsEditing = false
        self.navigationController.present(module, animated: true)
    }
    
    func closePicker() {
        self.navigationController.dismiss(animated: true, completion: nil)
        self.delegate = nil
        finish?()
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
