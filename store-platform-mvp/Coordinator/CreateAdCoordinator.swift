import UIKit

// MARK: - CreateAdCoordinator
class CreateAdCoordinator: BaseCoordinator, Coordinator {
    var navigationController: UINavigationController
    weak var delegate: ImagePickerDelegate?
    
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
    
    func openCreateSize(with item: Size? = nil) {
        let module = CreateSizeAssembler.buildCreateSizeModule(coordinator: self, model: item)
        
        self.navigationController.present(module, animated: true)
    }
    
    func openEditSize(item: Size) {
        openCreateSize(with: item)
    }
    
    func closeCreateSize() {
        self.navigationController.dismiss(animated: true, completion: nil)
    }
    
    func addNewSizeItem(_ item: Size) {
//        delegate?.createSize(size: item, completion: { [weak self] result in
//            switch result {
//            case .success(_):
//                self?.closeCreateSize()
//            case .failure(let error):
//                debugPrint(error)
//            }
//        })
    }
    
    func editSizeItem(_ item: Size) {
//        delegate?.editSize(size: item, completion: { [weak self] result in
//            switch result {
//            case .success(_):
//                self?.closeCreateSize()
//            case .failure(let error):
//                debugPrint(error)
//            }
//        })
    }
    
    func showImagePicker() {
        let imagePickerCoordinator = ImagePickerCoordinator(navigationController)
        
        imagePickerCoordinator.finishFlow = { [weak self, weak imagePickerCoordinator] image in
            guard let imagePickerCoordinator = imagePickerCoordinator else { return }
            self?.removeDependency(imagePickerCoordinator)
            
            guard let image = image else { return }
            self?.delegate?.didImageAdded(image: image)
        }

        addDependency(imagePickerCoordinator)
        imagePickerCoordinator.start()
    }
    
    func openDetailedImage(data: Data) {
        let module = DetailedImageAssembler.buildDetailedImageModule(image: data)
        
        self.navigationController.pushViewController(module, animated: true)
    }
    
    func finish() {
        self.navigationController.popViewController(animated: true)
        self.finishFlow?()
    }
}
