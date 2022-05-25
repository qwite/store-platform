import UIKit

protocol CreateAdCoordinatorProtocol {
    func didSelectImage(image: Data)
}

class CreateAdCoordinator: Coordinator {
    var navigationController: UINavigationController
    weak var delegate: CreateAdViewPresenterProtocol?
    var childCoordinator = [Coordinator]()
    var factory: Factory
    
    required init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
        factory = DependencyFactory()
    }
        
    func start() {
        let module = factory.buildCreateAdModule(coordinator: self)
        self.navigationController.pushViewController(module, animated: false)
    }
    
    func openCreateSize(with item: Size? = nil) {
        let module = factory.buildCreateSizeModule(coordinator: self, with: item)
        self.navigationController.present(module, animated: true)
    }
    
    func openEditSize(item: Size) {
        openCreateSize(with: item)
    }
    
    func closeCreateSize() {
        self.navigationController.dismiss(animated: true, completion: nil)
    }
    
    func addNewSizeItem(_ item: Size) {
        delegate?.createSize(size: item, completion: { result in
            switch result {
            case .success(_):
                // maybe memory leak -> TODO: fix
                self.closeCreateSize()
            case .failure(let error):
                debugPrint(error)
            }
        })
    }
    
    func editSizeItem(_ item: Size) {
        delegate?.editSize(size: item, completion: { result in
            switch result {
            case .success(_):
                debugPrint("[CreateAdCoordinator] success action")
                self.closeCreateSize()
            case .failure(_):
                debugPrint("")
            }
        })
    }
    
    func openImagePicker() {
        let imagePickerCoordinator = ImagePickerCoordinator(navigationController)
        imagePickerCoordinator.delegate = self
        imagePickerCoordinator.start()
    }
    
    func openDetailedImage(data: Data) {
        let module = factory.buildDetailedImageModule(image: data)
        self.navigationController.pushViewController(module, animated: true)
    }
}

// MARK: - CreateAdCoordinator Protocol
extension CreateAdCoordinator: CreateAdCoordinatorProtocol {
    func didSelectImage(image: Data) {
        delegate?.addImage(image: image)
    }
}
