import UIKit

// MARK: - TabBarViewProtocol
protocol TabBarViewProtocol: AnyObject {}

// MARK: - TabBarController
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

// MARK: - TabBarViewProtocol Implementation
extension TabBarController: TabBarViewProtocol {
    
}

// MARK: - UITabBarControllerDelegate
extension TabBarController: UITabBarControllerDelegate {}
