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

        let pages: [TabElements] = TabElements.allCases
        let navigations: [UINavigationController] = pages.map { element in
            if element.isDisabled() {
                return setForGuest(element)
            } else {
                return setForUser(element)
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
    
    func setForUser(_ page: TabElements) -> UINavigationController {
        let tabImage = UIImage(systemName: page.getIcon())
        let navigation = UINavigationController()
        switch page {
        case .feed:
            let coordinator = FeedCoordinator(navigation)
            coordinator.start()
            childCoordinator.append(coordinator)
        case .createAd:
            let coordinator = CreateAdCoordinator(navigation)
            coordinator.start()
            childCoordinator.append(coordinator)
        case .settings:
            let test = "s"
        }
        navigation.tabBarItem.image = tabImage
        return navigation
    }
    
    func setForGuest(_ page: TabElements) -> UINavigationController {
        let tabImage = UIImage(systemName: page.getIcon())
        let navigation = UINavigationController()
        navigation.setNavigationBarHidden(true, animated: false)
        navigation.tabBarItem.image = tabImage
        return navigation
    }
    
    func selectTabPage(index: Int) {
        if TabElements.allCases[index].isDisabled() {
            pushGuestModule(index: index)
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
        let image = UIImage(systemName: TabElements.allCases[index].getIcon())
        navigation.tabBarItem.image = image
        tabController.selectedIndex = index
    }
}

extension TabCoordinator {
    enum TabElements: CaseIterable {
        case feed
        case createAd
        case settings
        
        func getIcon() -> String {
            switch self {
            case .feed:
                return "square.and.pencil"
            case .createAd:
                return "plus"
            case .settings:
                return "eye"
            }
        }
        
        func isDisabled() -> Bool {
            switch self {
            case .feed:
                return false
            case .createAd:
                return false
            case .settings:
                return true
            }
        }
    }
}
