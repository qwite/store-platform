import UIKit

class ImagePickerCoordinator: Coordinator {
    var navigationController: UINavigationController
    
    var finishFlow: ((Data?) -> (Void))?
        
    func start() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            self.navigationController.present(sheetAlert(), animated: true )
        } else {
            showPicker()
        }
    }
    
    required init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func showPicker(with source: UIImagePickerController.SourceType = .photoLibrary) {
        let module = ImagePickerAssembler.buildImagePickerModule(coordinator: self, source: source)
        
        self.navigationController.present(module, animated: true)
    }
    
    func closePicker(with image: Data) {
        self.navigationController.dismiss(animated: true)
        self.finishFlow?(image)
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
