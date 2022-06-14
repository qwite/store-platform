import UIKit

protocol ProfileViewProtocol: AnyObject {
    func configure(with fullName: [String: String])
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
        profileView.profileNameLabel.text = "\(fullName["firstName"]!) \(fullName["lastName"]!)"
    }
    
    func configureViews() {
        profileView.configureViews()
    }
    
    func configureButtons() {
        profileView.logoutButton.addTarget(self, action: #selector(logoutButtonAction), for: .touchUpInside)
        profileView.communicationWithStoreButton.addTarget(self, action: #selector(communicationButtonAction), for: .touchUpInside)
    }
    
    @objc func logoutButtonAction() {
        presenter.didLogout()
    }
    
    @objc func communicationButtonAction() {
        presenter.didShowMessageList()
    }
}
