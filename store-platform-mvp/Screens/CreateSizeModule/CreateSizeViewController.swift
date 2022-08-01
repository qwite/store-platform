import UIKit
import SPAlert

// MARK: - CreateSizeViewProtocol
protocol CreateSizeViewProtocol: AnyObject {
    func configure()
    func configureButtons()
    func setSegmentedControlSource(items: [String])
    func didCloseScreen()
    func loadSavedValues(item: Size)
    func validateFields() -> Size?
    func showError(message: String)
}

// MARK: - CreateSizeViewController
class CreateSizeViewController: UIViewController {
    @objc private var preferredHeightInBottomSheet: CGFloat { return 340 }

    let createSizeView = CreateSizeView()
    var presenter: CreateSizePresenter!
    
    // MARK: Lifecycle
    override func loadView() {
        view = createSizeView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewDidLoad()
    }
}

// MARK: - CreateSizeViewProtocol Implementation
extension CreateSizeViewController: CreateSizeViewProtocol {
    func configure() {
        configureButtons()
        createSizeView.configure()
    }
    
    func configureButtons() {
        createSizeView.button.addTarget(self, action: #selector(self.didCloseScreen), for: .touchUpInside)
    }
    
    func loadSavedValues(item: Size) {
        guard let selectedIndex = Size.AvailableSizes.allCases.firstIndex(where: { $0.rawValue == item.size }) else {
            showError(message: Constants.Errors.loadingDataError); return
        }
        
        createSizeView.sizeSegmentedControl.selectedSegmentIndex = selectedIndex
        createSizeView.sizeSegmentedControl.isEnabled = false
        createSizeView.amountTextField.text = "\(item.amount)"
        createSizeView.priceTextField.text = "\(item.price)"
    }
    
    @objc func didCloseScreen() {
        guard let size = validateFields() else {
            showError(message: Constants.Errors.emptyFieldsError); return
        }
        
        guard presenter.editMode != nil else {
            return presenter.addSizeItem(size: size)
        }
        
        presenter.editSizeItem(size: size)
    }
    
    func validateFields() -> Size? {
        guard let priceTextFieldValue = createSizeView.priceTextField.text,
              let amountTextFieldValue = createSizeView.amountTextField.text else {
            return nil
        }
        
        let sizeIndex = createSizeView.sizeSegmentedControl.selectedSegmentIndex
        guard sizeIndex > 0 else {
            return nil
        }
        
        guard let price = Int(priceTextFieldValue),
              let amount = Int(amountTextFieldValue) else {
            return nil
        }
        
        let selectedSize = Size.AvailableSizes.allCases[sizeIndex]
        let size = Size(size: selectedSize, price: price, amount: amount)
        
        return size
    }
    
    func showError(message: String) {
        SPAlert.present(message: message, haptic: .error)
    }
    
    func setSegmentedControlSource(items: [String]) {
        for val in 0..<items.count {
            let title = items[val]
            createSizeView.sizeSegmentedControl.insertSegment(withTitle: title, at: val, animated: true)
        }
    }
}

