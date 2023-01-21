import UIKit

// MARK: - ImagePickerViewProtocol
protocol ImagePickerViewProtocol: AnyObject {
    func configure()
}

class ImagePickerController: UIImagePickerController {
    var presenter: ImagePickerPresenter!
    
    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate = self
        
        presenter.viewDidLoad()
    }
    
    deinit {
        presenter.finish()
    }
}


// MARK: - ImagePickerViewProtocol Implementation
extension ImagePickerController: ImagePickerViewProtocol {
    func configure() {
        self.allowsEditing = false
    }
}

// MARK: - UIImagePickerControllerDelegate & UINavigationControllerDelegate
extension ImagePickerController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let image = info[.originalImage] as? UIImage, let pngData = image.pngData() else {
            return
        }
        
        presenter.didClosePicker(with: pngData)
    }
}
