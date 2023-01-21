import UIKit

extension UINavigationController {
    func setCustomAppearance () {
        let titleFontAttrs = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18, weight: .semibold)]
        let backIndicatorImage = UIImage(systemName: "arrow.left")?.withTintColor(.black,
                                                                                  renderingMode: .alwaysOriginal)
        self.navigationBar.standardAppearance.setBackIndicatorImage(backIndicatorImage,
                                                                    transitionMaskImage: backIndicatorImage)
        self.navigationBar.standardAppearance.titleTextAttributes = titleFontAttrs
        self.navigationBar.tintColor = .red
    }
}
