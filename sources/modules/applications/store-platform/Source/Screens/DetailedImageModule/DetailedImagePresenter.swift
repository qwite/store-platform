import Foundation

// MARK: - DetailedImagePresenterProtocol
protocol DetailedImagePresenterProtocol {
    init(view: DetailedImageViewProtocol, with image: Data)
    func viewDidLoad()
}

// MARK: - DetailedImagePresenterProtocol Implementation
class DetailedImagePresenter: DetailedImagePresenterProtocol {
    var image: Data
    weak var view: DetailedImageViewProtocol?
    
    required init(view: DetailedImageViewProtocol, with image: Data) {
        self.view = view
        self.image = image
    }
    
    func viewDidLoad() {
        view?.configureViews()
        view?.setImage(image)
    }
}
