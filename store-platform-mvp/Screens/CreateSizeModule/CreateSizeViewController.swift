import UIKit

// MARK: - CreateSizeViewProtocol
protocol CreateSizeViewProtocol: AnyObject {
    func configure()
    func configureButtons()
    func setSegmentedControlSource(items: [String])
    func didCloseScreen()
    func loadSavedValues(item: Size)
}

// MARK: - CreateSizeViewController
class CreateSizeViewController: UIViewController {
    let createSizeView = CreateSizeView()
    var presenter: CreateSizePresenter!
    
    // MARK: Lifecycle
    override func loadView() {
        view = createSizeView
        view.backgroundColor = .white
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
        guard let size = item.size,
              let amount = item.amount,
              let price = item.price else {
            fatalError("Unwraping Size error")
        }
        
        let selectedIndex = Size.AvailableSizes.allCases.firstIndex {$0.rawValue == size}!
        createSizeView.sizeSegmentedControl.selectedSegmentIndex = selectedIndex
        createSizeView.sizeSegmentedControl.isEnabled = false
        createSizeView.amountTextField.text = "\(amount)"
        createSizeView.priceTextField.text = "\(price)"
    }
    
    // TODO: Add Error handling
    @objc func didCloseScreen() {
        guard let priceTextFieldValue = createSizeView.priceTextField.text,
              let amountTextFieldValue = createSizeView.amountTextField.text else {
            return
        }
        
        let sizeIndex = createSizeView.sizeSegmentedControl.selectedSegmentIndex
        
        let price = Int(priceTextFieldValue)
        let amount = Int(amountTextFieldValue)
        
        guard let editMode = presenter.editMode else {
            return presenter.addSizeItem(sizeIndex: sizeIndex, price: price, amount: amount)
        }
        presenter.editSizeItem(sizeIndex: sizeIndex, price: price, amount: amount)
    }
    
    func setSegmentedControlSource(items: [String]) {
        for val in 0..<items.count {
            let title = items[val]
            createSizeView.sizeSegmentedControl.insertSegment(withTitle: title, at: val, animated: true)
        }
    }
}

