import UIKit

class SizePickerAssembler {
    static func buildSizePickerModule(coordinator: SizePickerCoordinatorProtocol, with item: Item) -> UIViewController {
        let view = SizePickerViewController()
        let presenter = SizePickerPresenter(view: view, item: item, coordinator: coordinator)
        view.presenter = presenter
        return view
    }
}
