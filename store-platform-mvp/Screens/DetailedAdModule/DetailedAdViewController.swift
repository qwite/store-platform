import UIKit
import SPAlert

// MARK: - DetailedAdViewProtocol
protocol DetailedAdViewProtocol: AnyObject {
    func configure(with item: Item)
    func showSizePicker()
    func showSuccessAlert(message: String)
    func showChat()
    func configureReviews(reviews: [Review]?)
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

// MARK: - DetailedAdViewProtocol Implementation
extension DetailedAdViewController: DetailedAdViewProtocol {
    func configure(with item: Item) {
        detailedAdView.configure(with: item)
    }
    
    func showSizePicker() {
        presenter.showSizePicker()
    }
    
    func showSuccessAlert(message: String) {
        SPAlert.present(title: "", message: message, preset: .done)
    }
    
    func showChat() {
        presenter.createConversation()
    }
    
    func configureReviews(reviews: [Review]?) {
        detailedAdView.createReviewStack(reviews: reviews)
    }
}

// MARK: - UIScrollViewDelegate
extension DetailedAdViewController: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        let page = scrollView.contentOffset.x / scrollView.frame.size.width
        detailedAdView.pageControl.currentPage = Int(page)
    }
}

// MARK: - DetailedAdViewDelegate
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
    
    func didTappedSubscriptionButton() {
        presenter.addToSubscriptions()
    }
}
