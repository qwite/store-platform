import Foundation

// MARK: - BaseCoordinator
class BaseCoordinator: NSObject {
    var childCoordinators: [Coordinator] = []
    
    func addDependency(_ coordinator: Coordinator) {
        for element in childCoordinators {
            if element === coordinator { return }
        }
        childCoordinators.append(coordinator)
    }
    
    func removeDependency(_ coordinator: Coordinator) {
        guard childCoordinators.isEmpty == false else {
            return
        }
        
        for (index, element) in childCoordinators.enumerated() {
            if element === coordinator {
                childCoordinators.remove(at: index)
                debugPrint("removed from childs: \(coordinator)")
            }
        }
    }
    
    func removeAllGuestPages() {
        childCoordinators.removeAll(where: { $0 is GuestCoordinator })
    }
    
    func removeAllPages() {
        childCoordinators.removeAll()
    }
}
