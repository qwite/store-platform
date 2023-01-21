import UIKit

extension UIStackView {
    convenience init(arrangedSubviews: [UIView],
                     spacing: CGFloat,
                     axis: NSLayoutConstraint.Axis,
                     alignment: Alignment) {
        self.init(arrangedSubviews: arrangedSubviews)
        self.spacing = spacing
        self.axis = axis
        self.alignment = alignment
    }
}
