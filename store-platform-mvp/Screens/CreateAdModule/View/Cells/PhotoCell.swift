import UIKit

// MARK: - PhotoCellDelegate
protocol PhotoCellDelegate: AnyObject {
    func didTappedAddPhotoButton()
}

// MARK: - PhotoCell
class PhotoCell: UICollectionViewCell {
    
    // MARK: Properties
    static let reuseId = "Photo"
    weak var delegate: PhotoCellDelegate?
    
    lazy var imageView = UIImageView(image: nil, contentMode: .scaleAspectFit, clipToBounds: false)
}

extension PhotoCell {
    func configureViews(with image: UIImage) {
        addSubview(imageView)
        imageView.image = image
        imageView.snp.makeConstraints { make in
            make.edges.equalTo(snp.edges)
        }
    }
    
    func addPlaceholder() {
        let button = UIButton()
        imageView.image = UIImage(systemName: "plus.viewfinder")?.withTintColor(.lightGray, renderingMode: .alwaysOriginal)
        button.addTarget(self, action: #selector(addButtonPressed), for: .touchUpInside)
        addSubview(button)
        button.addSubview(imageView)
        
        button.snp.makeConstraints { make in
            make.edges.equalTo(snp.edges)
        }
        
        imageView.snp.makeConstraints { make in
            make.height.equalTo(button.snp.height).dividedBy(2)
            make.width.equalTo(button.snp.width).dividedBy(2)
            make.center.equalTo(button.snp.center)
        }
    }
    
    @objc private func addButtonPressed() {
        delegate?.didTappedAddPhotoButton()
    }
}
