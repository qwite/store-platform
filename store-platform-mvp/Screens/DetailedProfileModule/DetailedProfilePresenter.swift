import Foundation

// MARK: - DetailedProfilePresenterProtocol
protocol DetailedProfilePresenterProtocol {
    init(view: DetailedProfileViewProtocol, coordinator: ProfileCoordinator, service: UserServiceProtocol)
    func viewDidLoad()
    
    func fetchUserData()
    func updateUserData(data: UserDetails)
}

// MARK: - DetailedProfilePresenterProtocol Implementation
class DetailedProfilePresenter: DetailedProfilePresenterProtocol {
    weak var view: DetailedProfileViewProtocol?
    weak var coordinator: ProfileCoordinator?
    var service: UserServiceProtocol?
    
    required init(view: DetailedProfileViewProtocol, coordinator: ProfileCoordinator, service: UserServiceProtocol) {
        self.view = view
        self.coordinator = coordinator
        self.service = service
    }
    
    func viewDidLoad() {
        self.fetchUserData()
    }
    
    func fetchUserData() {
        guard let userId = SettingsService.sharedInstance.userId else { return }
        service?.fetchUserData(by: userId, completion: { [weak self] result in
            switch result {
            case .success(let userData):
                self?.view?.configure(data: userData)
            case .failure(let error):
                debugPrint(error)
            }
        })
    }
    
    func updateUserData(data: UserDetails) {
        guard let userId = SettingsService.sharedInstance.userId else { return }
        service?.updateUserData(by: userId, data: data) { [weak self] error in
            guard error == nil else { debugPrint("error"); return }
            
            self?.view?.showSuccessAlert()
        }
    }
}
