import UIKit
import SPAlert
import MultiSlider

protocol SortingFeedViewProtocol {    
    func configureViews()
    func configureButtons()
    func showErrorAlert()
    
    func updateColors(colors: [String])
    func updateSizes(sizes: [String])
    func updatePrice(price: [Float])
}

class SortingFeedViewController: UIViewController {
    var presenter: SortingFeedPresenterProtocol!
    var sortingFeedView = SortingFeedView()
    @objc var preferredHeightInBottomSheet: CGFloat { return 600.0 }
    
    override func loadView() {
        view = sortingFeedView
    }
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewDidLoad()
        view.backgroundColor = .white

    }
}

extension SortingFeedViewController: SortingFeedViewProtocol {
    func updateColors(colors: [String]) {
        if colors.count > 2 {
            // FIXME: lol
            sortingFeedView.selectedColorLabel.text = "\(colors[0]), \(colors[1]), ..."
        } else {
            sortingFeedView.selectedColorLabel.text = colors.joined(separator: ", ")
        }
    }
    
    func updateSizes(sizes: [String]) {
        sortingFeedView.selectedSizeLabel.text = sizes.joined(separator: ", ")
    }
    
    func updatePrice(price: [Float]) {
        sortingFeedView.selectedPriceLabel.text = "От \(Int(price[0])) до \(Int(price[1]))"
    }
    
    func configureViews() {
        sortingFeedView.configureViews()
        sortingFeedView.configureSlider()
        sortingFeedView.slider.addTarget(self, action: #selector(sliderDragEnded(_:)), for: .touchUpInside)
    }
    

    func configureButtons() {
        sortingFeedView.newItemsRadioButton.delegate = self
        sortingFeedView.newItemsRadioButton.type = .newItems
        
        sortingFeedView.popularItemsRadioButton.delegate = self
        sortingFeedView.popularItemsRadioButton.type = .popularItems
        
        sortingFeedView.byIncreasingPriceRadioButton.delegate = self
        sortingFeedView.byIncreasingPriceRadioButton.type = .byIncreasingPrice
        
        sortingFeedView.byDecreasingPriceRadioButton.delegate = self
        sortingFeedView.byDecreasingPriceRadioButton.type = .byDecreasingPrice
        
        sortingFeedView.colorButton.addTarget(self, action: #selector(colorButtonAction), for: .touchUpInside)
        sortingFeedView.sizeButton.addTarget(self, action: #selector(sizeButtonAction), for: .touchUpInside)
        sortingFeedView.priceButton.addTarget(self, action: #selector(priceButtonAction), for: .touchUpInside)
        
        sortingFeedView.resultButton.addTarget(self, action: #selector(resultButtonAction), for: .touchUpInside)
        sortingFeedView.clearButton.addTarget(self, action: #selector(resetButtonAction), for: .touchUpInside)
    }
    
    @objc private func resultButtonAction() {
        presenter.showResults()
    }
    
    @objc private func colorButtonAction() {
        presenter.showColorParameters()
    }
    
    @objc private func sizeButtonAction() {
        presenter.showSizeParameters()
    }
    
    @objc private func priceButtonAction() {
        sortingFeedView.showSlider()
    }
    
    @objc private func resetButtonAction() {
        presenter.clearSortSettings()
    }
    
    @objc private func sliderDragEnded(_ sender: Any) {
        guard let slider = sender as? MultiSlider else { return }
        let floatValues: [Float] = slider.value.map({ Float($0) })
        presenter.setSelectedPrice(price: floatValues)
    }
    
    
    func showErrorAlert() {
        SPAlert.present(message: "Для этого действия нужно выбрать параметры", haptic: .error)
    }
}

extension SortingFeedViewController: RadioButtonDelegate {
    func didButtonPressed(_ sender: UIView) {
        guard let currentRadioButton = sender as? RadioButton,
              let type = currentRadioButton.type else {
            return
        }
        
        let radioButtons = [sortingFeedView.newItemsRadioButton,
                            sortingFeedView.popularItemsRadioButton,
                            sortingFeedView.byIncreasingPriceRadioButton,
                            sortingFeedView.byDecreasingPriceRadioButton
                            ]
        
        radioButtons.forEach({ $0.isChecked = false })
        
        currentRadioButton.isChecked = !currentRadioButton.isChecked
        presenter.buttonWasPressed(with: type)
    }
}
