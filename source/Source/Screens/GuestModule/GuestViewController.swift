import UIKit

// MARK: - GuestView Protocol
protocol GuestViewProtocol: AnyObject {
    func configureViews()
    func configureButtons()
    func didTappedLoginButton()
    func didTappedRegisterButton()
}

class GuestViewController: UIViewController {
    var presenter: GuestPresenter!
    var guestView = GuestView()
    //MARK: - Lifecycle
    
    override func loadView() {
        view = guestView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewDidLoad()
    }
    
    deinit {
        print("guestvc deinit")
    }
}

// MARK: - GuestView Protocol implementation
extension GuestViewController: GuestViewProtocol {
    func configureViews() {
        guestView.configure()
    }
    
    func configureButtons() {
        guestView.loginButton.addTarget(self, action: #selector(didTappedLoginButton), for: .touchUpInside)
        guestView.registerButton.addTarget(self, action: #selector(didTappedRegisterButton), for: .touchUpInside)
    }
    
    @objc func didTappedLoginButton() {
        presenter.openLogin()
    }
    
    @objc func didTappedRegisterButton() {
        presenter.openRegister()
    }
}
