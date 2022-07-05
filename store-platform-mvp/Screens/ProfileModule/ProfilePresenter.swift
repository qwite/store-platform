import Foundation

protocol ProfilePresenterDelegate: AnyObject {
    func didTappedLogoutButton()
}

protocol ProfilePresenterProtocol {
    init(view: ProfileViewProtocol, service: UserServiceProtocol, coordinator: ProfileCoordinator)
    func viewDidLoad()
    func viewWillAppear()
    
    func getFullName()
    func didLogout()
    func didShowMessageList()
    func didShowUserOrders()
    func didShowDetailedProfile()
    func didShowSettings()
    func didShowSubscriptions()
}

class ProfilePresenter: ProfilePresenterProtocol {
    weak var view: ProfileViewProtocol?
    var service: UserServiceProtocol?
    weak var coordinator: ProfileCoordinator?
    
    required init(view: ProfileViewProtocol, service: UserServiceProtocol, coordinator: ProfileCoordinator) {
        self.view = view
        self.service = service
        // MARK: fix
        self.coordinator = coordinator
        coordinator.delegate = self
    }
    
    func viewDidLoad() {
        view?.configureViews()
        view?.configureButtons()
    }
    
    func viewWillAppear() {
        getFullName()
    }
    
    func getFullName() {
        guard let userId = SettingsService.sharedInstance.userId else { return }
        FirestoreService.sharedInstance.fetchUserData(by: userId) { result in
            switch result {
            case .success(let userData):
                guard let firstName = userData.firstName,
                      let lastName = userData.lastName else { return }
                
                let dict: [String: String] = ["firstName": firstName, "lastName": lastName]
                self.view?.configure(with: dict)
            case .failure(let error):
                debugPrint(error)
            }
        }
    }
    
    func didShowDetailedProfile() {
        coordinator?.showDetailedProfile()
    }
    
    func didLogout() {
        coordinator?.showLogoutAlert()
    }
    
    func didShowMessageList() {
        coordinator?.showListMessages()
    }
    
    func didShowUserOrders() {
        coordinator?.showUserOrders()
    }
    
    func didShowSettings() {
        coordinator?.showSettings()
    }
    
    func didShowSubscriptions() {
        coordinator?.showSubscriptions()
    }
}

extension ProfilePresenter: ProfilePresenterDelegate {
    func didTappedLogoutButton() {
        service?.logout(completion: { error in
            guard error == nil else {
                fatalError()
            }
            
            self.coordinator?.updateTabPages()
        })
    }
}

