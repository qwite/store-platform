import Foundation

// MARK: - FillBrandDataPresenterProtocol
protocol FillBrandDataPresenterProtocol {
    init(view: FillBrandDataViewProtocol, coordinator: OnboardingCoordinator, service: BrandServiceProtocol, builder: BrandBuilderProtocol)
    func viewDidLoad()
    
    func showImagePicker()
    func setBrandData(_ brandName: String, _ desc: String, _ city: String, _ firstName: String, _ lastName: String, _ patronymic: String)
    func createBrand(brand: Brand)
    func addLogo(image: Data)
    func finish()
}

// MARK: - FillBrandDataPresenterProtocol Implementation
class FillBrandDataPresenter: FillBrandDataPresenterProtocol {
    weak var view: FillBrandDataViewProtocol?
    weak var coordinator: OnboardingCoordinator?
    var service: BrandServiceProtocol?
    var builder: BrandBuilderProtocol?
    
    required init(view: FillBrandDataViewProtocol, coordinator: OnboardingCoordinator, service: BrandServiceProtocol, builder: BrandBuilderProtocol) {
        self.view = view
        self.coordinator = coordinator
        self.service = service
        self.builder = builder
    }
    
    func viewDidLoad() {
        view?.configure()
    }
    
    func showImagePicker() {
        coordinator?.showImagePicker()
    }
    
    func setBrandData(_ brandName: String, _ desc: String, _ city: String, _ firstName: String, _ lastName: String, _ patronymic: String) {
        builder?.setBrandName(brandName)
        builder?.setDescription(desc)
        builder?.setCity(city)
        builder?.setFirstName(firstName)
        builder?.setLastName(lastName)
        builder?.setPatronymic(patronymic)
        
        guard let brand = builder?.build() else { return }
        self.createBrand(brand: brand)
    }
    
    func createBrand(brand: Brand) {
        guard let userId = SettingsService.sharedInstance.userId else {
            return
        }
        
        service?.createBrand(brand: brand, userId: userId, completion: { [weak self] error in
            guard error == nil else {
                print(error!); return
            }
            
            self?.finish()
        })
    }
    
    func addLogo(image: Data) {
        service?.uploadBrandImage(data: image, completion: { [weak self] result in
            switch result {
            case .success(let logoUrl):
                self?.builder?.setLogo(logoUrl)
                self?.view?.reloadLogoImage(image: image)
            case .failure(let error):
                print(error)
            }
        })
    }
    
    func finish() {
        coordinator?.hideOnboarding()
    }
}

// MARK: - ImagePickerDelegate
extension FillBrandDataPresenter: ImagePickerDelegate {
    func didImageAdded(image: Data) {
        self.addLogo(image: image)
    }
}

