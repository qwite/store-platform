import UIKit

class OnboardingCoordinator: BaseCoordinator, Coordinator {
    var navigationController: UINavigationController
    var completionHandler: (() -> ())?
    
    func start() {
        let module = OnboardingAssembler.buildOnboardingModule(coordinator: self)
    
        self.navigationController.pushViewController(module, animated: false)
    }
    
    required init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func showFillBrandData() {
        guard let module = FillBrandDataAssembler.buildFillBrandDataModule(coordinator: self) as? FillBrandDataViewController else {
            return
        }
        
        self.navigationController.pushViewController(module, animated: true)
    }
    
    func showImagePicker() {
        let imagePickerCoordinator = ImagePickerCoordinator(self.navigationController)
        self.addDependency(imagePickerCoordinator)
        imagePickerCoordinator.start()
    }
    
    func hideOnboarding() {
        self.navigationController.popToRootViewController(animated: true)
        self.navigationController.viewControllers.removeAll()
        completionHandler?()
    }
}
