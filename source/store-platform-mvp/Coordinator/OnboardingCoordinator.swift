import UIKit

class OnboardingCoordinator: BaseCoordinator, Coordinator {
    var navigationController: UINavigationController
    var finishFlow: (() -> (Void))?
    weak var imageDelegate: ImagePickerDelegate?
    
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
        
    func hideOnboarding() {
        self.navigationController.popToRootViewController(animated: true)
        self.navigationController.viewControllers.removeAll()
        finishFlow?()
    }
}

extension OnboardingCoordinator: ImageCoordinatorProtocol {
    func showDetailedImage(data: Data) {
        let module = DetailedImageAssembler.buildDetailedImageModule(image: data)
        
        self.navigationController.pushViewController(module, animated: true)
    }
    
    func showImagePicker() {
        let imagePickerCoordinator = ImagePickerCoordinator(self.navigationController)
        imagePickerCoordinator.finishFlow = { [weak self, weak imagePickerCoordinator] image in
            guard let imagePickerCoordinator = imagePickerCoordinator else { return }
            self?.removeDependency(imagePickerCoordinator)
            
            guard let image = image else { return }
            self?.imageDelegate?.didImageAdded(image: image)
        }
        
        addDependency(imagePickerCoordinator)
        imagePickerCoordinator.start()
    }
}
