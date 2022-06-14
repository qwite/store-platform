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
}

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
        service?.getUserFullName(completion: { [weak self] result in
            switch result {
            case .success(let dict):
                self?.view?.configure(with: dict)
            case .failure(let error):
                fatalError("\(error)")
            }
        })
    }
    
    func didLogout() {
        coordinator?.showLogoutAlert()
    }
    
    func didShowMessageList() {
        coordinator?.showListMessages()
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

