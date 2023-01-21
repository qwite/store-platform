import Foundation

// MARK: - ProfilePresenterDelegate
protocol ProfilePresenterDelegate: AnyObject {
    func didTappedLogoutButton()
}

// MARK: - ProfilePresenterProtocol
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

// MARK: - ProfilePresenterProtocol Implementation
class ProfilePresenter: ProfilePresenterProtocol {
    weak var view: ProfileViewProtocol?
    var service: UserServiceProtocol?
    weak var coordinator: ProfileCoordinator?
    
    required init(view: ProfileViewProtocol, service: UserServiceProtocol, coordinator: ProfileCoordinator) {
        self.view = view
        self.service = service
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
        service?.fetchUserData(by: userId) { result in
            switch result {
            case .success(let userData):                
                let firstName = userData.firstName
                let lastName = userData.lastName
                
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

// MARK: - ProfilePresenterDelegate
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

