import UIKit

// MARK: - Coordinator Protocol
protocol Coordinator: AnyObject {
    var navigationController: UINavigationController { get set }
    func start()
    
    init(_ navigationController: UINavigationController)
}
