import UIKit

protocol SearchViewDelegate: AnyObject {
    func didTappedCategoryButton(_ category: String)
}

class SearchView: UIView {
    weak var delegate: SearchViewDelegate?
    
    let tshirtButton = UIButton(text: "Футболка", preset: .profile)
    let hoodieButton = UIButton(text: "Толстовка", preset: .profile)
    let pantsButton = UIButton(text: "Брюки", preset: .profile)
    let sweatеrButton = UIButton(text: "Кофта", preset: .profile)
    let jeansButton = UIButton(text: "Джинсы", preset: .profile)
    let jacketButton = UIButton(text: "Куртка", preset: .profile)
    let shirtButton = UIButton(text: "Рубашка", preset: .profile)
    let jerseyButton = UIButton(text: "Джерси", preset: .profile)
    
    let stack = UIStackView()
}

extension SearchView {
    public func configure() {
        configureViews()
        configureButtons()
    }
    
    private func configureViews() {
        backgroundColor = .white
        addStack()
    }
    
    private func addStack() {
        stack.spacing = 10
        stack.alignment = .fill
        stack.axis = .vertical
        
        let categories = [tshirtButton, hoodieButton, pantsButton, sweatеrButton, jeansButton, jacketButton, shirtButton, jerseyButton]
        
        for category in categories {
            stack.addArrangedSubview(category)
        }
        
        addSubview(stack)
        stack.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide.snp.top)
            make.left.equalTo(snp.left).offset(20)
            make.right.equalTo(snp.right).offset(-20)
        }
    }
    
    private func removeStack() {
        
    }
    
    private func configureButtons() {
        let categories = [tshirtButton, hoodieButton, pantsButton, sweatеrButton, jeansButton, jacketButton, shirtButton, jerseyButton]
        
        for button in categories {
            button.addTarget(self, action: #selector(categoryButtonTarget(_:)), for: .touchUpInside)
        }
    }
    
    @objc private func categoryButtonTarget(_ sender: UIButton) {
        guard let title = sender.titleLabel?.text else {
            return
        }
        
        delegate?.didTappedCategoryButton(title)
    }
}
