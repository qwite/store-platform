import Foundation

protocol DetailedImageViewProtocol: AnyObject {
    func setImage(_ image: Data)
}

protocol DetailedImagePresenterProtocol {
    init(view: DetailedImageViewProtocol, with image: Data)
    func viewDidLoad()
}

class DetailedImagePresenter: DetailedImagePresenterProtocol {
    var image: Data
    weak var view: DetailedImageViewProtocol?
    required init(view: DetailedImageViewProtocol, with image: Data) {
        self.view = view
        self.image = image
    }
    
    func viewDidLoad() {
        view?.setImage(image)
    }
}
