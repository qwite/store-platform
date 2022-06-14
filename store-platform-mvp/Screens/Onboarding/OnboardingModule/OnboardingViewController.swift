import UIKit

protocol OnboardingViewProtocol: AnyObject {
    func configure()
    func configureButtons()
    func didTappedContinueButton()
}

class OnboardingViewController: UIViewController {
    var welcomeView = WelcomePageView()
    var presenter: OnboardingPresenterProtocol!
    // MARK: Lifecycle
    override func loadView() {
        view = welcomeView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewDidLoad()
    }
}

extension OnboardingViewController: OnboardingViewProtocol {
    func configure() {
        configureButtons()
        welcomeView.configureViews()
    }
    
    func configureButtons() {
        welcomeView.button.addTarget(self, action: #selector(didTappedContinueButton), for: .touchUpInside)
    }
    
    @objc func didTappedContinueButton() {
        presenter.showFillBrandData()
    }
}
