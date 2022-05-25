import UIKit

protocol Coordinator {
    var navigationController: UINavigationController { get set }
    var childCoordinator: [Coordinator] { get set }
    func start()
    init(_ navigationController: UINavigationController)
}
