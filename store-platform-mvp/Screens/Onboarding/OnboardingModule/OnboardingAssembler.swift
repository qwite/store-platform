import UIKit

// MARK: - OnboardingAssembler
class OnboardingAssembler {
    static func buildOnboardingModule(coordinator: OnboardingCoordinator) -> UIViewController {
        let view = OnboardingViewController()
        let presenter = OnboardingPresenter(view: view, coordinator: coordinator)
        view.presenter = presenter
        return view
    }
}
