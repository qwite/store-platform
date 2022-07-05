import UIKit
import SPAlert

protocol DetailedProfileViewProtocol: AnyObject {
    func configure(data: UserData)
    func configureButtons()
    func showSuccessAlert()
}

class DetailedProfileViewController: UIViewController {
    var presenter: DetailedProfilePresenterProtocol!
    var detailedProfileView = DetailedProfileView()
    
    override func loadView() {
        view = detailedProfileView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        presenter.viewDidLoad()
    }
}

extension DetailedProfileViewController: DetailedProfileViewProtocol {
    func showSuccessAlert() {
        SPAlert.present(title: "Успех", message: "Данные сохранены", preset: .done)
    }
    
    func configure(data: UserData) {
        detailedProfileView.configure(data: data)
        configureButtons()
    }
    
    func configureButtons() {
        detailedProfileView.saveDataButton.addTarget(self, action: #selector(saveDataAction), for: .touchUpInside)
    }
    
    @objc private func saveDataAction() {
        let phone = detailedProfileView.phoneTextField.text ?? nil
        let city = detailedProfileView.deliveryCityTextField.text ?? nil
        let street = detailedProfileView.deliveryStreetTextField.text ?? nil
        let house = detailedProfileView.deliveryHouseTextField.text ?? nil
        let apartment = detailedProfileView.deliveryApartmentTextField.text ?? nil
        let postalCode = detailedProfileView.deliveryPostalCodeTextField.text ?? nil
        
        let details = UserDetails(phone: phone, city: city, street: street, house: house, apartment: apartment, postalCode: postalCode)
        
        presenter.updateUserData(data: details)
    }
}
