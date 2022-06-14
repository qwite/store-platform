import UIKit

protocol DetailedImageViewProtocol: AnyObject {
    func setImage(_ image: Data)
}

class DetailedImageViewController: UIViewController {
    var presenter: DetailedImagePresenter!
    lazy var imageView = UIImageView(image: nil, contentMode: .scaleAspectFit, clipToBounds: true)
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        presenter.viewDidLoad()
    }
}

// MARK: - Private Methods

extension DetailedImageViewController {
    private func setupViews() {
        view.backgroundColor = .white
        view.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.center.equalTo(view.snp.center)
            make.left.equalTo(view.snp.left).offset(20)
            make.right.equalTo(view.snp.right).offset(-20)
            make.height.equalTo(500)
        }
    }
}

// MARK: - DetailedImageView Protocol

extension DetailedImageViewController: DetailedImageViewProtocol {
    func setImage(_ image: Data) {
        let image = UIImage(data: image)
        imageView.image = image
    }
}
