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

        presenter.viewDidLoad()
    }
    
    deinit {
        presenter.finish()
        debugPrint("[Log] Detailed vc deinit")
    }
}

// MARK: - DetailedAdViewProtocol Implementation
extension DetailedAdViewController: DetailedAdViewProtocol {
    func configure(with item: Item) {
        detailedAdView.photoScrollView.delegate = self
        detailedAdView.scrollView.delegate = self
        detailedAdView.delegate = self
        
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
        guard scrollView == detailedAdView.photoScrollView else {
            return
        }
        
        let page = scrollView.contentOffset.x / scrollView.frame.size.width
        detailedAdView.pageControl.currentPage = Int(page)
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        guard scrollView == detailedAdView.scrollView else {
            return
        }
        
        print(targetContentOffset.pointee.y)
        if targetContentOffset.pointee.y >= -90 {
            detailedAdView.addCartButton.isHidden = false
        } else {
            detailedAdView.addCartButton.isHidden = true
        }
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
