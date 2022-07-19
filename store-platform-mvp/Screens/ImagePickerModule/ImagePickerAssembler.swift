import UIKit

// MARK: - ImagePickerAssembler
class ImagePickerAssembler {
    static func buildImagePickerModule(coordinator: ImagePickerCoordinator, delegate: ImagePickerPresenterDelegate) -> UIImagePickerController {
        let view = ImagePickerController()
        let presenter = ImagePickerPresenter(coordinator: coordinator, view: view)
        presenter.delegate = delegate
        view.presenter = presenter
        return view
    }
}
