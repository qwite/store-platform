import UIKit

// MARK: - DetailedImageAssembler
class DetailedImageAssembler {
    static func buildDetailedImageModule(image: Data) -> UIViewController {
        let view = DetailedImageViewController()
        let presenter = DetailedImagePresenter(view: view, with: image)
        view.presenter = presenter
        return view
    }
}
