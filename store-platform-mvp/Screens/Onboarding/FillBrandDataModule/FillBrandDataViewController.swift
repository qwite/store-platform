import UIKit

protocol FillBrandDataViewProtocol: AnyObject {
    func configure()
    func configureButtons()
    func didTappedSubmitButton()
    func reloadLogoImage(image: Data)
}

class FillBrandDataViewController: UIViewController {
    var presenter: FillBrandDataPresenterProtocol!
    var fillBrandView = FillBrandDataView()
    // MARK: - Lifecycle
    override func loadView() {
        view = fillBrandView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewDidLoad()
    }
}

extension FillBrandDataViewController: FillBrandDataViewProtocol {
    func configure() {
        title = "Заполните данные"
        fillBrandView.configureViews()
        configureButtons()
    }
    
    func configureButtons() {
        fillBrandView.addLogoButton.addTarget(self, action: #selector(didTappedAddLogoButton), for: .touchUpInside)
        fillBrandView.submitButton.addTarget(self, action: #selector(didTappedSubmitButton), for: .touchUpInside)
    }
    
    @objc func didTappedAddLogoButton() {
        presenter.showImagePicker()
    }
    
    @objc func didTappedSubmitButton() {
        guard let brandName = fillBrandView.brandNameTextField.text,
              let description = fillBrandView.descriptionTextField.text,
              let city = fillBrandView.deliveryCityTextField.text,
              let firstName = fillBrandView.firstNameTextField.text,
              let lastName = fillBrandView.lastNameTextField.text,
              let patronymic = fillBrandView.patronymicTextField.text else {
            // TODO: add view errors
            fatalError()
        }
        
        presenter.setBrandData(brandName, description, city, firstName, lastName, patronymic)
    }
    
    func reloadLogoImage(image: Data) {
        fillBrandView.updateImageConstraints()
        fillBrandView.logoImageView.image = UIImage(data: image)
    }
}
