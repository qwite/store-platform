import UIKit

protocol ProfileViewProtocol {
    
}

class ProfileViewController: UIViewController {
    var presenter: ProfilePresenterProtocol!
    var profileView = ProfileView()
    // MARK: - Lifecycle
    
    override func loadView() {
        view = profileView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        profileView.configureView()
    }
}

extension ProfileViewController: ProfileViewProtocol {
    
}
