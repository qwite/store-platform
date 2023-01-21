import UIKit

// MARK: - Extension for UIImage
extension UIImage {
    class func resizedImage(with data: Data, for size: CGSize) -> UIImage? {
        guard let image = UIImage(data: data) else {
            return nil
        }
        
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
