import UIKit
import SnapKit

extension UITextField {
    convenience init(placeholder: String, withUnderline underline: Bool = false, keyboardType: UIKeyboardType,
                     isSecureTextEntry: Bool = false) {
        self.init()
        self.placeholder = placeholder
        self.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        self.frame = CGRect(x: 0, y: 0, width: 200, height: 20)
        self.isSecureTextEntry = isSecureTextEntry
        self.keyboardType = keyboardType
        
        if underline {
            let lineView = UIView()
            lineView.backgroundColor = .lightGray
            lineView.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: 1)
            self.addSubview(lineView)
            
            lineView.snp.makeConstraints { make in
                make.top.equalTo(self.snp.bottom).offset(3)
                make.width.equalTo(self.snp.width)
                make.height.equalTo(1)
                make.left.equalTo(self.snp.left)
                make.right.equalTo(self.snp.right)
            }
        }
    }
}
