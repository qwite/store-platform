import UIKit

class CreateSizeViewController: UIViewController {
    let createSizeView = CreateSizeView()
    var presenter: CreateSizePresenter!
    
    // MARK: - Lifecycle
    override func loadView() {
        view = createSizeView
        view.backgroundColor = .white
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.didLoad()
        configureButtons()
    }
    
    // MARK: - Configure Buttons in CreateSizeView
    func configureButtons() {
        createSizeView.button.addTarget(self, action: #selector(self.didCloseScreen), for: .touchUpInside)
    }
}

extension CreateSizeViewController: CreateSizeViewProtocol {
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
        let sizeIndex = createSizeView.sizeSegmentedControl.selectedSegmentIndex
        let price = Int(createSizeView.priceTextField.text!)
        let amount = Int(createSizeView.amountTextField.text!)
        
        // TODO: Fix this I fell like stupid
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

// MARK: - SwiftUI
import SwiftUI
struct CreateSize: PreviewProvider {
    static var previews: some View {
        ContainerView().edgesIgnoringSafeArea(.all)
    }
    
    struct ContainerView: UIViewControllerRepresentable {
        
        func makeUIViewController(context: UIViewControllerRepresentableContext<CreateSize.ContainerView>)
        -> CreateSizeViewController {
            return CreateSizeViewController()
        }
        
        func updateUIViewController(_ uiViewController: CreateSize.ContainerView.UIViewControllerType,
                                    context: UIViewControllerRepresentableContext<CreateSize.ContainerView>) {}
    }
}
