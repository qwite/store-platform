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
    
    func removeDependency(_ coordinator: Coordinator) {
        guard childCoordinators.isEmpty == false else {
            return
        }
       
        for (index, element) in childCoordinators.enumerated() {
            if element === coordinator {
                childCoordinators.remove(at: index)
            }
        }
    }
    
    func removeAllGuest() {
        childCoordinators.removeAll()
    }
}
