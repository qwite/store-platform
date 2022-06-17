import UIKit

class SortingFeedView: UIView {
    
    let sortLabel = UILabel(text: nil, font: nil, textColor: .black)
    let newItemsRadioButton = RadioButton(text: "По новизне", preset: .radioButton)
    let popularItemsRadioButton = RadioButton(text: "По популярности", preset: .radioButton)
    let byIncreasingPriceRadioButton = RadioButton(text: "По цене: возрастание", preset: .radioButton)
    let byDecreasingPriceRadioButton = RadioButton(text: "По цене: убывание", preset: .radioButton)
    let resultButton = UIButton(text: "Показать результаты", preset: .bottom)
}

extension SortingFeedView {
    func configureViews() {
        sortLabel.text = "Сортировка"
        sortLabel.font = Constants.Fonts.mainTitleFont
        
        let sortingStack = UIStackView(arrangedSubviews: [sortLabel, newItemsRadioButton, popularItemsRadioButton, byIncreasingPriceRadioButton, byDecreasingPriceRadioButton], spacing: 20, axis: .vertical, alignment: .fill)
        
        addSubview(sortingStack)
        sortingStack.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide.snp.top).offset(20)
            make.left.equalTo(snp.left).offset(20)
            make.right.equalTo(snp.right).offset(-20)
        }
        
        addSubview(resultButton)
        resultButton.snp.makeConstraints { make in
            make.width.equalTo(196)
            make.height.equalTo(34)
            make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom).offset(-20)
            make.centerX.equalTo(snp.centerX)
        }
    }
}
