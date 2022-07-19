import UIKit

// MARK: - AvailableParametersPresenterAssembler
class AvailableParametersAssembler {
    static func buildAvailableParametersModule(delegate: AvailableParameterPresenterDelegate, type: Parameter.ParameterType) -> UIViewController {
        let view = AvailableParametersViewController()
        let presenter = AvailableParametersPresenter(view: view, delegate: delegate, type: type)
        view.presenter = presenter
        return view
    }
}
