import UIKit

// MARK: - CreateAdCoordinator
class CreateAdCoordinator: BaseCoordinator, Coordinator {
    var navigationController: UINavigationController
    weak var imageDelegate: ImagePickerDelegate?
    weak var createAdPresenterDelegate: CreateAdPresenterDelegate?
    
    var finishFlow: (() -> (Void))?
    
    deinit {
        debugPrint("[Log] CreateAd Coordinator deinit")
    }
    
    required init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
        
    func start() {
        let module = CreateAdAssembler.buildCreateAdModule(coordinator: self)
        
        self.navigationController.pushViewController(module, animated: true)
    }
    
    func showCreateSize(with item: Size? = nil) {
        let module = CreateSizeAssembler.buildCreateSizeModule(coordinator: self, model: item)
        
        self.navigationController.presentAsBottomSheet(module)
    }
    
    func showEditSize(item: Size) {
        showCreateSize(with: item)
    }
    
    func closeCreateSize() {
        self.navigationController.dismissBottomSheet()
    }
    
    func addNewSizeItem(_ item: Size) {
        createAdPresenterDelegate?.addSize(size: item)
    }
    
    func editSizeItem(_ item: Size) {
        createAdPresenterDelegate?.editSize(size: item)
    }
    
    func finish() {
        finishFlow?()
    }
}

// MARK: - ImageCoordinatorProtocol Implementation
extension CreateAdCoordinator: ImageCoordinatorProtocol {
    func showImagePicker() {
        let imagePickerCoordinator = ImagePickerCoordinator(navigationController)
        
        imagePickerCoordinator.finishFlow = { [weak self, weak imagePickerCoordinator] image in
            guard let imagePickerCoordinator = imagePickerCoordinator else { return }
            self?.removeDependency(imagePickerCoordinator)
            
            guard let image = image else { return }
            self?.imageDelegate?.didImageAdded(image: image)
        }

        addDependency(imagePickerCoordinator)
        imagePickerCoordinator.start()
    }
    
    func showDetailedImage(data: Data) {
        let module = DetailedImageAssembler.buildDetailedImageModule(image: data)
        
        self.navigationController.pushViewController(module, animated: true)
    }
}
