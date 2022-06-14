import UIKit

extension UIImageView {
    convenience init(image: UIImage?, contentMode: UIView.ContentMode? = .none, clipToBounds: Bool = false) {
        self.init()
        self.image = image
        if let contentMode = contentMode {
            self.contentMode = contentMode
        }
        
        self.clipsToBounds = clipToBounds
    }
}
