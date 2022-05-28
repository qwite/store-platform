import Foundation

class BaseCoordinator {
    var childCoordinators: [Coordinator] = []
    
    func addDependency(_ coordinator: Coordinator) {
        for element in childCoordinators {
            if element === coordinator { return }
        }
        childCoordinators.append(coordinator)
        debugPrint("appended: \(coordinator)")
    }
    
    func removeDependency(_ coordinator: GuestCoordinator) {
        guard childCoordinators.isEmpty == false else {
            return
        }
       
        for (index, element) in childCoordinators.enumerated() {
            if element is GuestCoordinator {
                childCoordinators.remove(at: index)
                debugPrint("removed: \(coordinator)")
            }
        }
    }
    
    func removeAllGuest() {
        childCoordinators.removeAll(where: {$0 is GuestCoordinator})
    }
}
