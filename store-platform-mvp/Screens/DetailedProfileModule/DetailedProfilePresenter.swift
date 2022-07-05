import Foundation

protocol DetailedProfilePresenterProtocol {
    init(view: DetailedProfileViewProtocol, coordinator: ProfileCoordinator)
    func viewDidLoad()
    
    func fetchUserData()
    func updateUserData(data: UserDetails)
}

class DetailedProfilePresenter: DetailedProfilePresenterProtocol {
    weak var view: DetailedProfileViewProtocol?
    weak var coordinator: ProfileCoordinator?
    
    required init(view: DetailedProfileViewProtocol, coordinator: ProfileCoordinator) {
        self.view = view
        self.coordinator = coordinator
    }
    
    func viewDidLoad() {
        self.fetchUserData()
    }
    
    func fetchUserData() {
        guard let userId = SettingsService.sharedInstance.userId else { return }
        FirestoreService.sharedInstance.fetchUserData(by: userId) { result in
            switch result {
            case .success(let userData):
                print(userData)
                self.view?.configure(data: userData)
            case .failure(let error):
                debugPrint(error)
            }
        }
    }
    
    func updateUserData(data: UserDetails) {
        guard let userId = SettingsService.sharedInstance.userId else { return }
        FirestoreService.sharedInstance.updateUserData(by: userId, data: data) { [weak self] error in
            guard error == nil else { debugPrint("error"); return }
            
            self?.view?.showSuccessAlert()
        }
    }
}
