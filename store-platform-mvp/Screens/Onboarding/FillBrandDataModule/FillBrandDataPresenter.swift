import Foundation

protocol FillBrandDataPresenterProtocol: ImagePickerPresenterDelegate {
    init(view: FillBrandDataViewProtocol, coordinator: OnboardingCoordinator, service: TOUserServiceProtocol)
    func viewDidLoad()
    func showImagePicker()
    func setBrandData(_ brandName: String, _ desc: String, _ city: String, _ firstName: String, _ lastName: String, _ patronymic: String)
    func createBrand(brand: Brand)
    func addLogo(image: Data)
    func finish()
}

class FillBrandDataPresenter: FillBrandDataPresenterProtocol {
    weak var view: FillBrandDataViewProtocol?
    weak var coordinator: OnboardingCoordinator?
    var service: TOUserServiceProtocol?
    //TODO: fix builder init
    var builder = BrandBuilderImpl()
    
    required init(view: FillBrandDataViewProtocol, coordinator: OnboardingCoordinator, service: TOUserServiceProtocol) {
        self.view = view
        self.coordinator = coordinator
        self.service = service
        coordinator.delegate = self
    }
    
    func viewDidLoad() {
        view?.configure()
    }
    
    func showImagePicker() {
        coordinator?.showImagePicker()
    }
    
    func setBrandData(_ brandName: String, _ desc: String, _ city: String, _ firstName: String, _ lastName: String, _ patronymic: String) {
        builder.setBrandName(brandName)
        builder.setDescription(desc)
        builder.setCity(city)
        builder.setFirstName(firstName)
        builder.setLastName(lastName)
        builder.setPatronymic(patronymic)
        
        let brand = builder.build()
        self.createBrand(brand: brand)
    }
    
    func createBrand(brand: Brand) {
        service?.createBrand(brand: brand, completion: { [weak self] result in
            switch result {
            case .success(let message):
                debugPrint("action complete with message: \(message)")
                self?.finish()
            case .failure(let error):
                fatalError("\(error)")
            }
        })
    }
    
    func addLogo(image: Data) {
        service?.uploadBrandLogoImage(data: image, completion: { [weak self] result in
            switch result {
            case .success(let logoUrl):
                self?.builder.setLogo(logoUrl)
                self?.view?.reloadLogoImage(image: image)
            case .failure(let error):
                fatalError("\(error)")
            }
        })
    }
    
    func finish() {
        coordinator?.hideOnboarding()
    }
}

// MARK: - ImagePickerPresenterDelegate
extension FillBrandDataPresenter: ImagePickerPresenterDelegate {
    func didCloseImagePicker(with imageData: Data) {
        self.addLogo(image: imageData)
    }
}

