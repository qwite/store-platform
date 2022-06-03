import UIKit

protocol PickSizeViewDelegate: AnyObject {
    func didTappedAddButton(selectedIndex: Int)
}

class PickSizeView: UIView {
    weak var delegate: PickSizeViewDelegate?
    let pickerView = UIPickerView()
    let label = UILabel(text: "Выберите размер",
                        font: .systemFont(ofSize: 18, weight: .semibold),
                        textColor: .black)
    let button = UIButton(text: "Добавить в корзину", preset: .bottom)
}

extension PickSizeView {
    
    func configurePickerView() {
        pickerView.isMultipleTouchEnabled = true
    }
    
    func configureButtons() {
        button.addTarget(self, action: #selector(addButtonAction), for: .touchUpInside)
    }
    
    @objc func addButtonAction() {
        let index = pickerView.selectedRow(inComponent: 0)
        delegate?.didTappedAddButton(selectedIndex: index)
    }
    
    func configureViews() {
        configurePickerView()
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
