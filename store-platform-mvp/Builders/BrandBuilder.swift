import Foundation

// MARK: - BrandBuilderProtocol
protocol BrandBuilderProtocol {
    var brandName: String? { get set }
    var description: String? { get set }
    var logo: String? { get set }
    var city: String? { get set }
    var firstName: String? { get set }
    var lastName: String? { get set }
    var patronymic: String? { get set }
    
    func setBrandName(_ name: String)
    func setDescription(_ description: String)
    func setLogo(_ url: String)
    func setCity(_ city: String)
    func setFirstName(_ name: String)
    func setLastName(_ name: String)
    func setPatronymic(_ patronymic: String)
    
    func build() -> Brand
}

// MARK: - BrandBuilderProtocol Implementation
final class BrandBuilderImpl: BrandBuilderProtocol {
    deinit {
        debugPrint("[Log] BrandBuilder deinit")
    }
    
    var brandName: String?
    var description: String?
    var logo: String?
    var city: String?
    var firstName: String?
    var lastName: String?
    var patronymic: String?
    
    func setBrandName(_ name: String) {
        self.brandName = name
    }
    
    func setDescription(_ description: String) {
        self.description = description
    }
    
    func setLogo(_ url: String) {
        self.logo = url
        debugPrint(url)
    }
    
    func setCity(_ city: String) {
        self.city = city
    }
    
    func setFirstName(_ name: String) {
        self.firstName = name
    }
    
    func setLastName(_ name: String) {
        self.lastName = name
    }
    
    func setPatronymic(_ patronymic: String) {
        self.patronymic = patronymic
    }
}

extension BrandBuilderImpl {
    func build() -> Brand {
        guard let brandName = brandName,
              let description = description,
              let logo = logo,
              let city = city,
              let firstName = firstName,
              let lastName = lastName,
              let patronymic = patronymic else {
            fatalError("\(BrandBuilderErrors.emptyFieldsError)")
        }
        
        let deliveryInfo = Delivery(city: city, firstName: firstName, lastName: lastName, patronymic: patronymic)
        let brand = Brand(brandName: brandName, description: description, logo: logo, delivery: deliveryInfo)
        return brand
    }
    
    enum BrandBuilderErrors: Error {
        case emptyFieldsError
    }
}
