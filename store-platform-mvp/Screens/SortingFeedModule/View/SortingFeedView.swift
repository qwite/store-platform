import UIKit
import MultiSlider

// MARK: - SortingFeedView
class SortingFeedView: UIView {
    
    // MARK: Properties
    let sortTitleLabel = UILabel(text: nil, font: nil, textColor: .black)
    let filterTitleLabel = UILabel(text: nil, font: nil, textColor: .black)
    
    let newItemsRadioButton = RadioButton(text: "По новизне", preset: .radioButton)
    let popularItemsRadioButton = RadioButton(text: "По популярности", preset: .radioButton)
    let byIncreasingPriceRadioButton = RadioButton(text: "По цене: возрастание", preset: .radioButton)
    let byDecreasingPriceRadioButton = RadioButton(text: "По цене: убывание", preset: .radioButton)
    
    let colorButton = UIButton(text: "Цвет", preset: .filterButton)
    let sizeButton = UIButton(text: "Размер", preset: .filterButton)
    let priceButton = UIButton(text: "Цена", preset: .filterButton)
    
    let selectedColorLabel = UILabel(text: nil, font: nil, textColor: .black)
    let selectedSizeLabel = UILabel(text: nil, font: nil, textColor: .black)
    let selectedPriceLabel = UILabel(text: nil, font: nil, textColor: .black)

    let slider = MultiSlider()
    let resultButton = UIButton(text: "Показать результаты", preset: .bottom)
    let clearButton = UIButton(text: "Очистить", preset: .clearButton)
}

// MARK: - Public methods
extension SortingFeedView {
    public func configure() {
        configureSlider()
        configureViews()
    }
    
    public func showSlider() {
        UIView.transition(with: slider, duration: 0.4, options: .transitionCrossDissolve) {
            self.slider.isHidden = false
        }
    }
    
}

// MARK: - Private methods
extension SortingFeedView {
    private func configureSlider() {
        slider.isHidden = true
        
        slider.minimumValue = 1000
        slider.maximumValue = 20000
        slider.value = [1000, 20000]
        slider.orientation = .horizontal
        slider.valueLabelPosition = .bottom
        slider.valueLabelFormatter.positiveSuffix = " ₽"
        slider.valueLabelColor = .black
        slider.tintColor = .darkGray
        slider.thumbTintColor = .black
        slider.snapStepSize = 1000
        
        self.changeThumbSizes()
    }
    
    private func changeThumbSizes() {
        slider.thumbViews.forEach { imageView in
            imageView.heightAnchor.constraint(equalToConstant: 15).isActive = true
            imageView.widthAnchor.constraint(equalToConstant: 15).isActive = true
        }
    }
        
    private func configureViews() {
        sortTitleLabel.text = "Сортировка"
        sortTitleLabel.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
        
        filterTitleLabel.text = "Фильтрация"
        filterTitleLabel.font = UIFont.systemFont(ofSize: 24, weight: .semibold)

        selectedColorLabel.text = "Все"
        selectedColorLabel.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        
        selectedSizeLabel.text = "Все"
        selectedSizeLabel.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        
        selectedPriceLabel.text = "Любая"
        selectedPriceLabel.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        
        let sortingStack = UIStackView(arrangedSubviews: [sortTitleLabel, newItemsRadioButton, popularItemsRadioButton, byIncreasingPriceRadioButton, byDecreasingPriceRadioButton], spacing: 20, axis: .vertical, alignment: .fill)
        
        addSubview(sortingStack)
        sortingStack.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide.snp.top).offset(20)
            make.left.equalTo(snp.left).offset(20)
            make.right.equalTo(snp.right).offset(-20)
        }
                
        let filterStack = UIStackView(arrangedSubviews: [filterTitleLabel, colorButton, sizeButton, priceButton], spacing: 20, axis: .vertical, alignment: .fill)
        
        addSubview(filterStack)
        filterStack.snp.makeConstraints { make in
            make.top.equalTo(sortingStack.snp.bottom).offset(30)
            make.left.equalTo(snp.left).offset(20)
            make.right.equalTo(snp.right).offset(-20)
        }
        
        colorButton.addSubview(selectedColorLabel)
        selectedColorLabel.snp.makeConstraints { make in
            make.right.equalTo(colorButton.snp.right)
        }
        
        sizeButton.addSubview(selectedSizeLabel)
        selectedSizeLabel.snp.makeConstraints { make in
            make.right.equalTo(sizeButton.snp.right)
        }
        
        priceButton.addSubview(selectedPriceLabel)
        selectedPriceLabel.snp.makeConstraints { make in
            make.right.equalTo(priceButton.snp.right)
        }
        
        addSubview(slider)
        slider.snp.makeConstraints { make in
            make.top.equalTo(filterStack.snp.bottom).offset(0)
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
        
        addSubview(clearButton)
        clearButton.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide.snp.top)
            make.right.equalTo(snp.right).offset(-20)
            make.width.equalTo(80)
            make.height.equalTo(20)
        }
    }
}
