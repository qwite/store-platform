import UIKit

class ProfileView: UIView {
    lazy var label = UILabel(text: "Профиль", font: .systemFont(ofSize: 14, weight: .semibold), textColor: .black)
    
    func configureView() {
        backgroundColor = .white
        addSubview(label)
        
        label.snp.makeConstraints { make in
            make.center.equalTo(snp.center)
        }
    }
}
