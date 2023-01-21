import Foundation

// MARK: - CreateAdPresenterDelegate
protocol CreateAdPresenterDelegate: AnyObject {
    func addSize(size: Size)
    func editSize(size: Size)
}

// MARK: - CreateAdPresenterProtocol
protocol CreateAdPresenterProtocol {
    init(view: CreateAdViewProtocol, itemBuilder: ItemBuilderProtocol, coordinator: CreateAdCoordinator, service: BrandServiceProtocol)
    func viewDidLoad()
    func finish()
    
    func editSizeView(_ item: Size)
    func setCategory(_ category: String)
    func setClothingName(_ name: String)
    func setDescription(_ description: String)
    func addImage(image: Data)
    var photos: [Data]? { get set }
}

// MARK: - CreateAdPresenterProtocol Implementation
class CreateAdPresenter: CreateAdPresenterProtocol {
    var photos: [Data]?
    
    weak var view: CreateAdViewProtocol?
    var itemBuilder: ItemBuilderProtocol?
    var service: BrandServiceProtocol?
    weak var coordinator: CreateAdCoordinator?
    
    required init(view: CreateAdViewProtocol, itemBuilder: ItemBuilderProtocol, coordinator: CreateAdCoordinator, service: BrandServiceProtocol) {
        self.view = view
        self.itemBuilder = itemBuilder
        self.coordinator = coordinator
        self.service = service
    }
    
    func viewDidLoad() {
        view?.configureCollectionView()
        view?.configureDataSource()
        view?.insertPlaceholders()
    }
    
    func finish() {
        coordinator?.finish()
    }
        
    @objc func openSizeView() {
        coordinator?.showCreateSize()
    }
    
    func editSizeView(_ item: Size) {
        coordinator?.showEditSize(item: item)
    }
    
    func setCategory(_ category: String) {
        itemBuilder?.setCategory(category)
    }
    
    func setColor(_ color: String) {
        itemBuilder?.setColor(color)
    }
    
    func showImagePicker() {
        coordinator?.showImagePicker()
    }
    
    // TODO: Need a fix
    func addImage(image: Data) {
        if photos == nil {
            photos = []
        }
        
        photos?.append(image)
        view?.insertImage(image)
    }
    
    func setClothingName(_ name: String) {
        itemBuilder?.setClothingName(name)
    }
    
    func setDescription(_ description: String) {
        itemBuilder?.setDescription(description)
    }
    
    func buildProduct() {
        guard let userId = SettingsService.sharedInstance.userId else {
            return
        }
        
        guard let photos = self.photos else {
            debugPrint("Photos not added"); return
        }
        
        service?.getBrandName(by: userId, completion: { [weak self] result in
            switch result {
            case .success(let brandName):
                self?.itemBuilder?.setBrandName(brandName)
                var item = self?.itemBuilder?.build()
                
                self?.service?.uploadImages(with: photos, completion: { result in
                    switch result {
                    case .success(let urls):
                        item?.photos = urls
                        guard let item = item else {
                            return
                        }
                        
                        self?.service?.createNewAd(with: item, userId: userId, completion: { error in
                            guard error == nil else { self?.view?.showErrorAlert("\(error!)"); return }
                            
                            self?.view?.showSuccessAlert()
                            self?.finish()
                        })
                    case .failure(let error):
                        self?.view?.showErrorAlert("\(error)")
                    }
                })
            case .failure(let error):
                self?.view?.showErrorAlert("\(error)")
            }
        })
    }
    
    func showImage(data: Data) {
        coordinator?.showDetailedImage(data: data)
    }
}

// MARK: - ImagePickerDelegate
extension CreateAdPresenter: ImagePickerDelegate {
    func didImageAdded(image: Data) {
        self.addImage(image: image)
    }
}

// MARK: - CreateAdPresenterDelegate Implementation
extension CreateAdPresenter: CreateAdPresenterDelegate {
    func addSize(size: Size) {
        guard let result = itemBuilder?.addSize(size) else {
            view?.showErrorAlert(Constants.Errors.sizeAddingError); return
        }
        
        view?.insertSizeSection(item: result)
        coordinator?.closeCreateSize()
    }
    
    func editSize(size: Size) {
        guard let result = itemBuilder?.editSize(item: size) else {
            view?.showErrorAlert(Constants.Errors.sizeEditingError); return
        }
        
        view?.updateSizeSection(item: result)
        coordinator?.closeCreateSize()
    }
}
