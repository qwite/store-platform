import UIKit

// MARK: - ChangeOrderStatusView
class ChangeOrderStatusView: UIView {
    
    // MARK: Properties
    let statusTitleLabel = UILabel(text: "Статус", font: .systemFont(ofSize: 18, weight: .semibold), textColor: .black)
    let pickerView = UIPickerView()
    let button = UIButton(text: "Изменить статус", preset: .bottom)
}

// MARK: - Public methods
extension ChangeOrderStatusView {
    public func configure() {
        configureViews()
    }
}

// MARK: - Private methods
extension ChangeOrderStatusView {
    private func configureViews() {
        backgroundColor = .white
        
        addSubview(statusTitleLabel)
        statusTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide.snp.top).offset(40)
            make.centerX.equalTo(snp.centerX)
        }
        
        addSubview(pickerView)
        pickerView.snp.makeConstraints { make in
            make.top.equalTo(statusTitleLabel.snp.bottom)
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
