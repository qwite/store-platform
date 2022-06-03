import UIKit

class CartView: UIView {
    let label = UILabel(text: "Корзина", font: .systemFont(ofSize: 14, weight: .semibold), textColor: .black)
}

extension CartView {
    func configureViews() {
        backgroundColor = .white
        
        addSubview(label)
        
        label.snp.makeConstraints { make in
            make.center.equalTo(snp.center)
        }
    }
}
