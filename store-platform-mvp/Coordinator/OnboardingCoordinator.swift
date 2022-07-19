import UIKit

class OnboardingCoordinator: BaseCoordinator, Coordinator {
    var navigationController: UINavigationController
    weak var delegate: ImagePickerPresenterDelegate?
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
        
        self.delegate = module.presenter
        self.navigationController.pushViewController(module, animated: true)
    }
    
    func showImagePicker() {
        let imagePickerCoordinator = ImagePickerCoordinator(self.navigationController)
        imagePickerCoordinator.delegate = self.delegate
        self.addDependency(imagePickerCoordinator)
        imagePickerCoordinator.start()
    }
    
    func hideOnboarding() {
        self.navigationController.popToRootViewController(animated: true)
        self.navigationController.viewControllers.removeAll()
        completionHandler?()
    }
}
