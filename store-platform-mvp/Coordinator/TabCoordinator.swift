import UIKit

class TabCoordinator: Coordinator {
    var navigationController: UINavigationController
    var factory: Factory
    var tabController: UITabBarController?
    var childCoordinator = [Coordinator]()
    var isSignIn = false
    var guestCoordinator: GuestCoordinator?
    
    required init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.factory = DependencyFactory()
    }
    
    func start() {
        tabController = factory.buildTabBarModule(coordinator: self)

        // TODO: improve this line
        let pages: [TabElements] = TabElements.allCases.sorted(by: {$0.pageNumber < $1.pageNumber})
        let navigations: [UINavigationController] = pages.map { element in
            if element.isDisabled {
                return pageForGuest(element)
            } else {
                return pageForUser(element)
            }
        }
        
        tabController?.viewControllers = navigations
        setTabBarAppearance()
        self.navigationController.pushViewController(tabController!, animated: true)
    }
    
    func setTabBarAppearance() {
        self.navigationController.setNavigationBarHidden(true, animated: true)
        tabController?.tabBar.backgroundColor = .white
        tabController?.tabBar.isTranslucent = false
        tabController?.tabBar.tintColor = .black

    }
    
    func pageForUser(_ page: TabElements) -> UINavigationController {
        let tabImage = UIImage(systemName: page.icon)
        let navigation = UINavigationController()
        switch page {
        case .feed:
            let coordinator = FeedCoordinator(navigation)
            coordinator.start()
            childCoordinator.append(coordinator)
        case .favs:
            let coordinator = FavoritesCoordinator(navigation)
            coordinator.start()
            childCoordinator.append(coordinator)
        case .createAd:
            let coordinator = CreateAdCoordinator(navigation)
            coordinator.start()
            childCoordinator.append(coordinator)
        case .settings:
            let test = "s"
        }
        
        navigation.navigationBar.topItem?.title = page.title
        navigation.tabBarItem.image = tabImage
        return navigation
    }
    
    func pageForGuest(_ page: TabElements) -> UINavigationController {
        let tabImage = UIImage(systemName: page.icon)
        let navigation = UINavigationController()
        navigation.tabBarItem.image = tabImage
        navigation.navigationBar.topItem?.title = page.title
        return navigation
    }
    
    func selectTabPage(index: Int) {
        guard let item = TabElements(index: index) else {
            return
        }
        
        let isAuth = SettingsService.sharedInstance.isAuthorized
        if item.isDisabled && !isAuth {
            pushGuestModule(index: item.pageNumber)
        }
    }
    
    func pushGuestModule(index: Int) {
        guard let tabController = tabController else {
            return
        }
            
        let navigation = UINavigationController()
        
        tabController.viewControllers?.remove(at: index)
        guestCoordinator = GuestCoordinator(navigation)
        guestCoordinator?.start()
        
        tabController.viewControllers?.insert(navigation, at: index)
        let image = UIImage(systemName: TabElements.init(index: index)!.icon)
        navigation.tabBarItem.image = image
        tabController.selectedIndex = index
    }
}

extension TabCoordinator {
    enum TabElements: CaseIterable {
        case feed
        case createAd
        case favs
        case settings
        
        init?(index: Int) {
            switch index {
            case 0:
                self = .feed
            case 1:
                self = .favs
            case 2:
                self = .settings
            case 3:
                self = .createAd
            default:
                return nil
            }
        }
        
        var title: String {
            switch self {
            case .feed:
                return "Лента"
            case .createAd:
                return "Создание"
            case .favs:
                return "Избранное"
            case .settings:
                return "Настройки"
            }
        }
        
        var pageNumber: Int {
            switch self {
            case .feed:
                return 0
            case .favs:
                return 1
            case .settings:
                return 2
            case .createAd:
                return 3
            }
        }
        
        var icon: String {
            switch self {
            case .feed:
                return "magnifyingglass"
            case .favs:
                return "heart"
            case .settings:
                return "eye"
            case .createAd:
                return "plus"
            }
        }
        
        var isDisabled: Bool {
            switch self {
            case .feed:
                return false
            case .favs:
                return false
            case .settings:
                return true
            case .createAd:
                return false
            }
        }
    }
}
