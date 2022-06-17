import UIKit
import SPAlert

protocol SortingFeedViewProtocol {
    func configureViews()
    func configureButtons()
    func showErrorAlert()
}

class SortingFeedViewController: UIViewController {
    var presenter: SortingFeedPresenterProtocol!
    var sortingFeedView = SortingFeedView()
    
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
    func configureViews() {
        sortingFeedView.configureViews()
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
        
        sortingFeedView.resultButton.addTarget(self, action: #selector(resultButtonAction), for: .touchUpInside)
    }
    
    @objc private func resultButtonAction() {
        presenter.showResults()
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
