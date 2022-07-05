import UIKit
import SPAlert

protocol DetailedOrderViewProtocol: AnyObject {
    func configure(order: Order)
    func configureButtons()
    func showSuccess()
    func showError()
}

class DetailedOrderViewController: UIViewController {
    @objc var preferredHeightInBottomSheet: CGFloat { return 600.0 }
    var presenter: DetailedOrderPresenterProtocol!
    var detailedOrderView = DetailedOrderView()
    
    // MARK: Lifecycle
    override func loadView() {
        view = detailedOrderView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        title = "Информация о заказе"
        
        presenter.viewDidLoad()
    }
}

extension DetailedOrderViewController: DetailedOrderViewProtocol {
    func showSuccess() {
        SPAlert.present(title: "", message: "Отзыв добавлен!", preset: .done, haptic: .success)
    }
    
    func showError() {
        SPAlert.present(title: "", message: "Произошла ошибка", preset: .error, haptic: .error)

    }
    
    func configure(order: Order) {
        detailedOrderView.configure(order: order)
    }
    
    func configureButtons() {
        detailedOrderView.communicationWithBrandButton.addTarget(self, action: #selector(communicationWithBrandButtonAction), for: .touchUpInside)
        detailedOrderView.addReviewButton.addTarget(self, action: #selector(addReviewButtonAction), for: .touchUpInside)
    }
    
    @objc private func communicationWithBrandButtonAction() {
        presenter.contactWithBrand()
    }
    
    @objc private func addReviewButtonAction() {
        print("here")
        guard let reviewText = detailedOrderView.reviewTextField.text else { fatalError() }
        let rating = detailedOrderView.cosmosView.rating
        presenter.addReview(text: reviewText, rating: rating)
    }
}
