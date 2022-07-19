import UIKit

class CreateAdCoordinator: BaseCoordinator, Coordinator {
    var navigationController: UINavigationController
    weak var delegate: CreateAdPresenterProtocol?
    weak var pickerDelegate: ImagePickerPresenterDelegate?
    
    var factory: Factory?
    var finishFlow: (() -> ())?
    
    deinit {
        debugPrint("create ad coordinator deinit")
    }
    
    required init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
        factory = DependencyFactory()
    }
        
    func start() {
        guard let module = CreateAdAssembler.buildCreateAdModule(coordinator: self) as? CreateAdViewController else {
            return
        }
        
        self.pickerDelegate = module.presenter
        self.navigationController.delegate = self
        self.navigationController.pushViewController(module, animated: true)
    }
    
    func openCreateSize(with item: Size? = nil) {
        guard let module = factory?.buildCreateSizeModule(coordinator: self, with: item) else {
            return
        }
        
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
    
    func showImagePicker() {
        let imagePickerCoordinator = ImagePickerCoordinator(navigationController)
        imagePickerCoordinator.delegate = self.pickerDelegate
        self.addDependency(imagePickerCoordinator)
        imagePickerCoordinator.start()
    }
    
    func openDetailedImage(data: Data) {
        guard let module = factory?.buildDetailedImageModule(image: data) else {
            return
        }
        
        self.navigationController.pushViewController(module, animated: true)
    }
    
    func finish() {
        self.navigationController.popViewController(animated: true)
        self.finishFlow?()
    }
}

extension CreateAdCoordinator: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        guard let fromViewController = navigationController.transitionCoordinator?.viewController(forKey: .from) else {
             return
         }

         // Check whether our view controller array already contains that view controller. If it does it means we’re pushing a different view controller on top rather than popping it, so exit.
         if navigationController.viewControllers.contains(fromViewController) {
             return
         }

         // We’re still here – it means we’re popping the view controller, so we can check whether it’s a buy view controller
         if let buyViewController = fromViewController as? CreateAdViewController {
             // We're popping a buy view controller; end its coordinator
             finish()
         }
    }
}
