import UIKit

// MARK: - ImagePickerAssembler
class ImagePickerAssembler {
    static func buildImagePickerModule(coordinator: ImagePickerCoordinator, source: UIImagePickerController.SourceType ) -> UIImagePickerController {
        let view = ImagePickerController()
        view.sourceType = source
        
        let presenter = ImagePickerPresenter(coordinator: coordinator, view: view)
        view.presenter = presenter
        return view
    }
}
