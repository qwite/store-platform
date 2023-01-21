import Foundation

// MARK: - MessagesListPresenterProtocol
protocol MessagesListPresenterProtocol {
    init(view: MessagesListViewProtocol, role: MessengerRole, service: BrandServiceProtocol, coordinator: MessagesCoordinatorProtocol)
    
    func viewDidLoad()
    func showMessenger(with id: String)
}

// MARK: - MessagesListPresenterProtocol Implementation
class MessagesListPresenter: MessagesListPresenterProtocol {
    weak var view: MessagesListViewProtocol?
    var role: MessengerRole
    var service: BrandServiceProtocol?
    weak var coordinator: MessagesCoordinatorProtocol?
    
    required init(view: MessagesListViewProtocol, role: MessengerRole, service: BrandServiceProtocol, coordinator: MessagesCoordinatorProtocol) {
        self.view = view
        self.role = role
        self.service = service
        
        self.coordinator = coordinator
    }
    
    func viewDidLoad() {
        view?.configureCollectionView()
        view?.configureDataSource()
        view?.configureViews()
        
        listenConversations()
    }
    
    func listenConversations() {
        switch role {
        case .user:
            fetchUserConversations { [weak self] conversations in
                guard let conversations = conversations else {
                    self?.view?.addConversationsPlaceholder(); return
                }
                
                self?.view?.insertConversations(data: conversations)
            }
        case .brand:
            fetchBrandConversations { [weak self] conversations in
                guard let conversations = conversations else {
                    self?.view?.addConversationsPlaceholder(); return
                }
                
                self?.view?.insertConversations(data: conversations)
            }
        }
    }
    
    func fetchBrandConversations(completion: @escaping ([Conversation]?) -> ()) {
        guard let userId = SettingsService.sharedInstance.userId else {
            return
        }
        
        service?.getBrandId(by: userId, completion: { result in
            guard let brandId = try? result.get() else {
                fatalError()
            }
            
            RealTimeService.sharedInstance.getAllConversationsForBrand(brandId: brandId) { result in
                switch result {
                case .success(let conversations):
                    completion(conversations)
                case .failure(let error):
                    completion(nil)
                    debugPrint(error)
                }
            }
        })
    }
    
    func fetchUserConversations(completion: @escaping ([Conversation]?) -> ()) {
        guard let userId = SettingsService.sharedInstance.userId else {
            fatalError()
        }
        
        RealTimeService.sharedInstance.getAllConversationsForUser(userId: userId) { result in
            switch result {
            case .success(let conversations):
                completion(conversations)
            case .failure(let error):
                completion(nil)
                debugPrint(error)
            }
        }
    }
    
    func showMessenger(with id: String) {
        guard let userId = SettingsService.sharedInstance.userId else {
            return
        }
        
        switch role {
        case .user:
            self.coordinator?.showMessenger(conversationId: id, brandId: nil)
        case .brand:
            service?.getBrandId(by: userId, completion: { [weak self] result in
                guard let brandId = try? result.get() else {
                    fatalError()
                }
                
                self?.coordinator?.showMessenger(conversationId: id, brandId: brandId)
            })
        }
    }
}
