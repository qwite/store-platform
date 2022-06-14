import UIKit

protocol AddItemButtonViewDelegate: AnyObject {
    func didTappedAddButton()
}

class AddItemButtonView: UICollectionReusableView {
    weak var delegate: AddItemButtonViewDelegate?
    static let reuseId = "AddItemButton"
    let button = UIButton(text: "Добавить товар", preset: .none)
}

extension AddItemButtonView {
    func configureViews() {
        addSubview(button)
        button.contentHorizontalAlignment = .left
        button.snp.makeConstraints { make in
            make.edges.equalTo(snp.edges)
        }
        
        configureButtons()
    }
    
    func configureButtons() {
        button.addTarget(self, action: #selector(addButtonTarget), for: .touchUpInside)
    }
    
    @objc func addButtonTarget() {
        delegate?.didTappedAddButton()
    }
}
