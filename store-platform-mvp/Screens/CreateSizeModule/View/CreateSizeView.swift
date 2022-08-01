import UIKit

// MARK: - CreateSizeView
class CreateSizeView: UIView {
    
    // MARK: Properties
    lazy var sizeHeaderLabel = UILabel(text: "Размер",
                                  font: UIFont.systemFont(ofSize: 18, weight: .bold),
                                  textColor: .black)
    
    lazy var sizeSegmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl()
        segmentedControl.tintColor = .white
        segmentedControl.backgroundColor = .white
        segmentedControl.layer.backgroundColor = UIColor.white.cgColor
        return segmentedControl
    }()
    
    lazy var priceHeaderLabel = UILabel(text: "Цена",
                                   font: UIFont.systemFont(ofSize: 18, weight: .bold),
                                   textColor: .black)
    
    lazy var priceTextField = UITextField(placeholder: "Цена за шт.",
                                     withUnderline: true,
                                     keyboardType: .numberPad)

    lazy var amountHeaderLabel = UILabel(text: "Количество",
                                   font: UIFont.systemFont(ofSize: 18, weight: .bold),
                                   textColor: .black)
    
    lazy var amountTextField = UITextField(placeholder: "1 шт.",
                                      withUnderline: true,
                                      keyboardType: .numberPad)
    
    lazy var button = UIButton(text: "Добавить товар", preset: .bottom)
}

// MARK: - Public methods
extension CreateSizeView {
    public func configure() {
        configureViews()
    }
}

// MARK: - Private methods
extension CreateSizeView {
    private func configureViews() {
        backgroundColor = .white
        
        let sizeStack = UIStackView(arrangedSubviews: [sizeHeaderLabel, sizeSegmentedControl])
        sizeStack.axis = .vertical
        sizeStack.spacing = 5
        
        let priceStack = UIStackView(arrangedSubviews: [priceHeaderLabel, priceTextField])
        priceStack.axis = .vertical
        priceStack.spacing = 5
        
        let countStack = UIStackView(arrangedSubviews: [amountHeaderLabel, amountTextField])
        countStack.axis = .vertical
        countStack.spacing = 5
        
        let stack = UIStackView(arrangedSubviews: [sizeStack, priceStack, countStack])
        stack.axis = .vertical
        stack.spacing = 20
        stack.alignment = .fill
        stack.distribution = .equalSpacing

        addSubview(stack)
        addSubview(button)
        stack.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide.snp.top).offset(10)
            make.left.equalTo(snp.left).offset(20)
            make.right.equalTo(snp.right).offset(-20)
        }
    
        button.snp.makeConstraints { make in
            make.top.equalTo(stack.snp.bottom).offset(20)
            make.centerX.equalTo(snp.centerX)
            make.width.equalTo(200)
            make.height.equalTo(34)
        }
    }
}


