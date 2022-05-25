import UIKit

protocol TabBarViewProtocol {
    
}

class TabBarController: UITabBarController {
    var presenter: TabBarPresenter!
    
    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
}

extension TabBarController: TabBarViewProtocol {
    
}

extension TabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        presenter.select(tabBarController.selectedIndex)
    }
}
