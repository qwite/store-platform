import Foundation

// MARK: - OnboardingPresenterProtocol
protocol OnboardingPresenterProtocol {
    init(view: OnboardingViewProtocol, coordinator: OnboardingCoordinator)
    func viewDidLoad()
    func showFillBrandData()
}

// MARK: - OnboardingPresenterProtocol Implementation
class OnboardingPresenter: OnboardingPresenterProtocol {
    weak var view: OnboardingViewProtocol?
    weak var coordinator: OnboardingCoordinator?
    
    required init(view: OnboardingViewProtocol, coordinator: OnboardingCoordinator) {
        self.view = view
        self.coordinator = coordinator
    }
    
    func viewDidLoad() {
        view?.configure()
    }
    
    func showFillBrandData() {
        coordinator?.showFillBrandData()
    }
}
