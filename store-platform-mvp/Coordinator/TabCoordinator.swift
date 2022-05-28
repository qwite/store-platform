import UIKit
import SwiftUI

// MARK: - TabCoordinator Delegate Protocol
protocol TabCoordinatorDelegate: AnyObject {
    func updatePages()
}

// MARK: - TabCoordinator
class TabCoordinator: BaseCoordinator, Coordinator {
    var navigationController: UINavigationController
    var factory: Factory?
    var tabController: UITabBarController?
    
    required init(_ navigationController: UINavigationController) {
        self.factory = DependencyFactory()
        self.navigationController = navigationController
    }
    
    func start() {
        // Building a controller
        tabController = factory?.buildTabBarModule(coordinator: self)
        setTabBarAppearance()
        // preparing pages
        preparePages()

        self.navigationController.pushViewController(tabController!, animated: true)
    }
    
    func preparePages() {
        let pages: [TabElements] = TabElements.allCases.sorted(by: {$0.pageNumber < $1.pageNumber})
        let isAuth = SettingsService.sharedInstance.isAuthorized
        let navigations: [UINavigationController] = pages.map { page in
            page.isDisabled && !isAuth ? pageForGuest(page) : pageForUser(page)
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
    
    func pageForUser(_ page: TabElements) -> UINavigationController {
        let tabImage = UIImage(systemName: page.icon)
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
        case .createAd:
            let coordinator = CreateAdCoordinator(navigation)
            addDependency(coordinator)
            coordinator.start()
        case .settings:
            let coordinator = CreateAdCoordinator(navigation)
            addDependency(coordinator)
            coordinator.start()
        case .profile:
            let coordinator = ProfileCoordinator(navigation)
            addDependency(coordinator)
            coordinator.start()
        }
        
        navigation.navigationBar.topItem?.title = page.title
        navigation.tabBarItem.image = tabImage
        return navigation
    }
    
    func pageForGuest(_ page: TabElements) -> UINavigationController {
        let tabImage = UIImage(systemName: page.icon)
        let navigation = UINavigationController()
        let coordinator = GuestCoordinator(navigation)

        self.addDependency(coordinator)
        coordinator.delegate = self
        coordinator.finish = { [weak self] in
            self?.removeAllGuest()
            debugPrint("child -> guest removed")
        }
        
        coordinator.start()
        navigation.tabBarItem.image = tabImage
        navigation.navigationBar.topItem?.title = page.title
        return navigation
    }
}

extension TabCoordinator: TabCoordinatorDelegate {
    func updatePages() {
        self.preparePages()
    }
}

extension TabCoordinator {
    enum TabElements: CaseIterable {
        case feed
        case createAd
        case favs
        case settings
        case profile
        
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
            case .createAd:
                return "Создание"
            case .favs:
                return "Избранное"
            case .settings:
                return "Настройки"
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
            case .settings:
                return 2
            case .createAd:
                return 3
            case .profile:
                return 4
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
            case .profile:
                return "person"
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
                return true
            case .profile:
                return true
            }
        }
    }
}
