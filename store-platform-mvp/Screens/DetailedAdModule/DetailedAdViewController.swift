import UIKit
import SPAlert

// MARK: - DetailedAdViewProtocol
protocol DetailedAdViewProtocol: AnyObject {
    func configure(with item: Item)
    func showSizePicker()
    func showSuccessAlert()
    func showChat()
}

// MARK: - DetailedAdViewController
class DetailedAdViewController: UIViewController {
    var presenter: DetailedAdPresenter!
    var detailedAdView = DetailedAdView()
    // MARK: - Lifecycle
    
    override func loadView() {
        view = detailedAdView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        detailedAdView.photoScrollView.delegate = self
        detailedAdView.delegate = self
        presenter.viewDidLoad()
    }
    
    deinit {
        debugPrint("detailed vc deinit")
    }
}

extension DetailedAdViewController: DetailedAdViewProtocol {
    func configure(with item: Item) {
        detailedAdView.configure(with: item)
        detailedAdView.configureViews()
        detailedAdView.configureButtons()
    }
    
    func showSizePicker() {
        presenter.showSizePicker()
    }
    
    func showSuccessAlert() {
        SPAlert.present(title: "Успешно", message: "Товар был добавлен в корзину", preset: .done)
    }
    
    func showChat() {
        presenter.createConversation()
    }
}

extension DetailedAdViewController: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        let page = scrollView.contentOffset.x / scrollView.frame.size.width
        detailedAdView.pageControl.currentPage = Int(page)
    }
}

extension DetailedAdViewController: DetailedAdViewDelegate {
    func didTappedCommunicationButton() {
        showChat()
    }
    
    func didTappedSelectSizeButton() {
        showSizePicker()
    }
    
    func didTappedAddCartButton() {
        showSizePicker()
    }
}
