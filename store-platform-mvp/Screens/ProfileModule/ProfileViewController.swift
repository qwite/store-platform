import UIKit

protocol ProfileViewProtocol: AnyObject {
    func configure(with fullName: [String : String])
    func configureViews()
    func configureButtons()
}

class ProfileViewController: UIViewController {
    var presenter: ProfilePresenterProtocol!
    var profileView = ProfileView()
    // MARK: - Lifecycle
    
    override func loadView() {
        view = profileView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.viewWillAppear()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewDidLoad()
    }
}

extension ProfileViewController: ProfileViewProtocol {
    func configure(with fullName: [String : String]) {
        guard let firstName = fullName["firstName"],
              let lastName = fullName["lastName"] else { return }
        
        profileView.profileNameLabel.text = "\(firstName) \(lastName)"
    }
    
    func configureViews() {
        profileView.configureViews()
    }
    
    func configureButtons() {
        profileView.logoutButton.addTarget(self, action: #selector(logoutButtonAction), for: .touchUpInside)
        profileView.communicationWithStoreButton.addTarget(self, action: #selector(communicationButtonAction), for: .touchUpInside)
        profileView.userOrdersButton.addTarget(self, action: #selector(userOrdersButtonAction), for: .touchUpInside)
        profileView.settingsButton.addTarget(self, action: #selector(settingsButtonAction), for: .touchUpInside)
        profileView.subscriptionsButton.addTarget(self, action: #selector(subscriptionsButtonAction), for: .touchUpInside)
        // gesture
        profileView.labelStack.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(profileInfoAction)))
    }
    
    @objc func logoutButtonAction() {
        presenter.didLogout()
    }
    
    @objc func communicationButtonAction() {
        presenter.didShowMessageList()
    }
    
    @objc func userOrdersButtonAction() {
        presenter.didShowUserOrders()
    }
    
    @objc func profileInfoAction() {
        presenter.didShowDetailedProfile()
    }
    
    @objc func settingsButtonAction() {
        presenter.didShowSettings()
    }
    
    @objc func subscriptionsButtonAction() {
        presenter.didShowSubscriptions()
    }
}
