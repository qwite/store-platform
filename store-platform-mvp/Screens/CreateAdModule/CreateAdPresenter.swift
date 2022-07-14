import Foundation

protocol CreateAdViewPresenterProtocol: AnyObject {
    init(view: CreateAdViewProtocol, itemBuilder: ItemBuilderProtocol, coordinator: CreateAdCoordinator, service: TOUserServiceProtocol)
    func viewDidLoad()
    
    func createSize(size: Size, completion: @escaping((Result<Size, Error>) -> Void))
    func editSize(size: Size, completion: @escaping ((Result<Size, Error>) -> Void))
    func editSizeView(_ item: Size)
    func setCategory(_ category: String)
    func setClothingName(_ name: String)
    func setDescription(_ description: String)
    func addImage(image: Data)
    func popScreen()
    var photos: [Data]? { get set }
}

class CreateAdPresenter: CreateAdViewPresenterProtocol {
    var photos: [Data]?
    
    weak var view: CreateAdViewProtocol?
    var itemBuilder: ItemBuilderProtocol
    var service: TOUserServiceProtocol?
    weak var coordinator: CreateAdCoordinator?
    
    required init(view: CreateAdViewProtocol, itemBuilder: ItemBuilderProtocol, coordinator: CreateAdCoordinator, service: TOUserServiceProtocol) {
        self.view = view
        self.itemBuilder = itemBuilder
        self.coordinator = coordinator
        self.coordinator?.delegate = self
        self.service = service
    }
    
    func viewDidLoad() {
        print("create ad loaded")
        view?.configureCollectionView()
        view?.configureDataSource()
    }
    
    func createSize(size: Size, completion: @escaping ((Result<Size, Error>) -> Void)) {
        guard let result = itemBuilder.addSize(size) else {
            return completion(.failure(ItemBuilder.ItemBuilderError.sizeExistError))
        }
        
        view?.insertSizeSection(item: result)
        completion(.success(result))
    }
    
    func editSize(size: Size, completion: @escaping ((Result<Size, Error>) -> Void)) {
        guard let result = itemBuilder.editSize(item: size) else {
            return completion(.failure(ItemBuilder.ItemBuilderError.indexNotFoundError))
        }
        
        view?.updateSizeSection(item: result)
        completion(.success(result))
    }
    
    @objc func openSizeView() {
        coordinator?.openCreateSize()
    }
    
    func editSizeView(_ item: Size) {
        coordinator?.openEditSize(item: item)
    }
    
    func setCategory(_ category: String) {
        itemBuilder.setCategory(category)
    }
    
    func setColor(_ color: String) {
        itemBuilder.setColor(color)
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
        itemBuilder.setClothingName(name)
    }
    
    func setDescription(_ description: String) {
        itemBuilder.setDescription(description)
    }
    
    func buildProduct() {
        guard let photos = self.photos else {
            return debugPrint("Photos not added")
        }
        
        service?.getBrandName(completion: { result in
            switch result {
            case .success(let brandName):
                self.itemBuilder.setBrandName(brandName)
                var item = self.itemBuilder.build()
                
                StorageService.sharedInstance.uploadItemImages(with: photos) { result in
                    switch result {
                    case .success(let urls):
                        item.photos = urls
                        self.service?.addItemToBrand(item: item, completion: { result in
                            switch result {
                            case .success(_):
                                self.view?.showSuccessAlert()
                                self.coordinator?.finish()
                            case .failure(let error):
                                self.view?.showErrorAlert("\(error)")
                            }
                        })
                    case .failure(let error):
                        fatalError()
                    }
                }
            case .failure(let error):
                fatalError()
            }
        })
    }
    
    func showImage(data: Data) {
        coordinator?.openDetailedImage(data: data)
    }
    
    func popScreen() {
        debugPrint("test")
    }
}

// MARK: - ImagePickerPresenterDelegate
extension CreateAdPresenter: ImagePickerPresenterDelegate {
    func didCloseImagePicker(with imageData: Data) {
        self.addImage(image: imageData)
    }
}
