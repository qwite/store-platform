import UIKit

// MARK: - SizePickViewDelegate Protocol
protocol SizePickViewDelegate: AnyObject {
    func didTappedAddButton(selectedIndex: Int)
}

// MARK: - SizePickView
class SizePickView: UIView {
    // MARK: Properties
    weak var delegate: SizePickViewDelegate?
    let pickerView = UIPickerView()
    let label = UILabel(text: nil,
                        font: nil,
                        textColor: .black)
    
    let button = UIButton(text: "Добавить в корзину", preset: .bottom)
}

// MARK: - Public methods
extension SizePickView {
    public func configure() {
        configurePickerView()
        configureButtons()
        configureViews()
    }
}

// MARK: - Private methods
extension SizePickView {
    private func configurePickerView() {
        pickerView.isMultipleTouchEnabled = true
    }
    
    private func configureButtons() {
        button.addTarget(self, action: #selector(addButtonAction), for: .touchUpInside)
    }
    
    @objc private func addButtonAction() {
        let index = pickerView.selectedRow(inComponent: 0)
        delegate?.didTappedAddButton(selectedIndex: index)
    }
    
    private func configureViews() {
        label.text = "Выберите размер"
        label.font = .systemFont(ofSize: 18, weight: .bold)
        
        backgroundColor = .white
        addSubview(label)
        
        label.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide.snp.top).offset(40)
            make.centerX.equalTo(snp.centerX)
        }
        
        addSubview(pickerView)
        pickerView.snp.makeConstraints { make in
            make.top.equalTo(label.snp.bottom)
            make.left.equalTo(snp.left).offset(20)
            make.right.equalTo(snp.right).offset(-20)
        }
        
        addSubview(button)
        button.snp.makeConstraints { make in
            make.top.equalTo(pickerView.snp.bottom)
            make.centerX.equalTo(snp.centerX)
            make.height.equalTo(34)
            make.width.equalTo(snp.width).dividedBy(2)
        }
    }
}
