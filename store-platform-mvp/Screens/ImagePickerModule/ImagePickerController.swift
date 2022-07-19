import UIKit

// MARK: - ImagePickerViewProtocol
protocol ImagePickerViewProtocol: AnyObject {}

class ImagePickerController: UIImagePickerController {
    var presenter: ImagePickerPresenter!
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        presenter.viewDidLoad()
    }
}


// MARK: - ImagePickerView Protocol
extension ImagePickerController: ImagePickerViewProtocol {}

// MARK: - UIImagePickerControllerDelegate & UINavigationControllerDelegate
extension ImagePickerController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[.originalImage] as? UIImage
        guard let image = image, let pngData = image.pngData() else {
            return
        }
        
        presenter.didClosePicker(with: pngData)
    }
}
