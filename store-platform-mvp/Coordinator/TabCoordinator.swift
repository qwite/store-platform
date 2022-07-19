import UIKit

// MARK: - TabCoordinatorDelegate Protocol
protocol TabCoordinatorDelegate: AnyObject {
    func updatePages()
}

// MARK: - TabCoordinator
class TabCoordinator: BaseCoordinator, Coordinator {
    var navigationController: UINavigationController
    var tabController: UITabBarController?
    
    required init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        // Building a controller
        let tabController = TabBarAssembler.buildTabBarModule(coordinator: self)
        self.tabController = tabController
        
        setTabBarAppearance()
        // preparing pages
        preparePages()

        self.navigationController.pushViewController(tabController, animated: true)
    }
    
    func preparePages() {
        let pages: [TabElements] = TabElements.allCases.sorted(by: {$0.pageNumber < $1.pageNumber})
        let isAuthStatus = SettingsService.sharedInstance.isAuthorized
        let navigations: [UINavigationController] = pages.compactMap { page in
            page.isDisabled && !isAuthStatus ? setPageForGuest(page) : setPageForUser(page)
        }
        
        tabController?.viewControllers = navigations
        tabController?.selectedIndex = 0
    }
    
    func setTabBarAppearance() {
        self.navigationController.setNavigationBarHidden(true, animated: true)
        tabController?.tabBar.backgroundColor = .white
        tabController?.tabBar.isTranslucent = false
        tabController?.tabBar.tintColor = .black
    }
    
    func setPageForUser(_ page: TabElements) -> UINavigationController {
        let tabImage = UIImage(named: page.icon)
        let navigation = UINavigationController()
        switch page {
        case .feed:
            let coordinator = FeedCoordinator(navigation)
            addDependency(coordinator)
            coordinator.start()
        case .favs:
            let coordinator = FavoritesCoordinator(navigation)
            addDependency(coordinator)
            coordinator.start()
        case .seller:
            let coordinator = SellerCoordinator(navigation)
            addDependency(coordinator)
            coordinator.start()
        case .bag:
            let coordinator = CartCoordinator(navigation)
            addDependency(coordinator)
            coordinator.start()
        case .profile:
            let coordinator = ProfileCoordinator(navigation)
            coordinator.tabDelegate = self
            addDependency(coordinator)
            coordinator.start()
        }
        
        navigation.navigationBar.topItem?.title = page.title
        navigation.navigationBar.prefersLargeTitles = true
        navigation.tabBarItem.image = tabImage
        return navigation
    }
    
    func resetTabController() {
        tabController?.viewControllers = []
        
        // BaseCoordinator method
        self.removeAllPages()
    }
    
    func setPageForGuest(_ page: TabElements) -> UINavigationController {
        let tabImage = UIImage(named: page.icon)
        let navigation = UINavigationController()
        let coordinator = GuestCoordinator(navigation)

        self.addDependency(coordinator)
        coordinator.delegate = self
        coordinator.finish = { [weak self] in
            self?.removeAllGuestPages()
        }
        
        coordinator.start()
        navigation.tabBarItem.image = tabImage
        navigation.navigationBar.topItem?.title = page.title
        return navigation
    }
}

// MARK: - TabCoordinatorDelegate
extension TabCoordinator: TabCoordinatorDelegate {
    func updatePages() {
        self.resetTabController()
        self.preparePages()
    }
}

// MARK: - Enum
extension TabCoordinator {
    enum TabElements: CaseIterable {
        case feed
        case seller
        case favs
        case bag
        case profile
        
        init?(index: Int) {
            switch index {
            case 0:
                self = .feed
            case 1:
                self = .favs
            case 2:
                self = .seller
            case 3:
                self = .bag
            case 4:
                self = .profile
            default:
                return nil
            }
        }
        
        var title: String {
            switch self {
            case .feed:
                return "Лента"
            case .seller:
                //TODO: fix
                return ""
            case .favs:
                return "Избранное"
            case .bag:
                return "Корзина"
            case .profile:
                return "Профиль"
            }
        }
        
        var pageNumber: Int {
            switch self {
            case .feed:
                return 0
            case .favs:
                return 1
            case .seller:
                return 2
            case .bag:
                return 3
            case .profile:
                return 4
            }
        }
        
        var icon: String {
            switch self {
            case .feed:
                return "feed"
            case .favs:
                return "favorites"
            case .seller:
                return "seller"
            case .bag:
                return "bag"
            case .profile:
                return "profile"
            }
        }
        
        var isDisabled: Bool {
            switch self {
            case .feed:
                return false
            case .favs:
                return false
            case .seller:
                return true
            case .bag:
                return false
            case .profile:
                return true
            }
        }
    }
}
