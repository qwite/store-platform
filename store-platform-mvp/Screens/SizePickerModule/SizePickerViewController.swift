import UIKit

// MARK: - SizePickerViewProtocol
protocol SizePickerViewProtocol: AnyObject {
    func configure()
    func getRowsCount() -> Int
    func getComponentCount() -> Int
    func selectIndex(index: Int)
}

// MARK: - SizePickerViewController
class SizePickerViewController: UIViewController {
    @objc var preferredHeightInBottomSheet: CGFloat { return 340 }
    
    var presenter: SizePickerPresenterProtocol!
    var sizePickView = SizePickView()
    
    // MARK: Lifecycle
    
    override func loadView() {
        view = sizePickView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewDidLoad()
    }
    
    deinit {
        debugPrint("Size picker deinit")
    }
}

// MARK: - SizePickerViewProtocol Implementation
extension SizePickerViewController: SizePickerViewProtocol {
    func configure() {
        sizePickView.configure()
        
        sizePickView.delegate = self
        sizePickView.pickerView.dataSource = self
        sizePickView.pickerView.delegate = self
    }
    
    func getRowsCount() -> Int {
        return presenter.getSizeRowsCount()
    }
    
    func getComponentCount() -> Int{
        return presenter.getSizeComponentCount()
    }
    
    func selectIndex(index: Int) {
        presenter.selectSize(by: index)
    }
}


// MARK: - UIPickerViewDelegate
extension SizePickerViewController: UIPickerViewDelegate {
    
}

// MARK: - UIPickerViewDataSource
extension SizePickerViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return getRowsCount()
    }
        
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 44.0
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return view.bounds.size.width
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let size = presenter.getAvailableSizes()
        
        let parentView = UIView(frame: .zero)
        
        let priceLabel = UILabel()
        
        if row == 0 || (row > 0 && size[row].price != size[row - 1].price) {
            priceLabel.text = "\(size[row].price) ₽"
        } else {
            priceLabel.text = ""
        }
        
        let sizeLabel = UILabel()
        sizeLabel.text = "\(size[row].size)"
        
        if size[row].amount == 1 {
            let lastItemHintLabel = UILabel()
            lastItemHintLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
            lastItemHintLabel.text = "Последний\nтовар"
            lastItemHintLabel.numberOfLines = 0
            lastItemHintLabel.textAlignment = .center
            
            parentView.addSubview(lastItemHintLabel)
            
            lastItemHintLabel.snp.makeConstraints { make in
                make.right.equalTo(parentView.snp.right).offset(-60)
                make.centerY.equalTo(parentView.snp.centerY)
            }
        }
        
        parentView.addSubview(priceLabel)
        parentView.addSubview(sizeLabel)

        priceLabel.snp.makeConstraints { make in
            make.left.equalTo(parentView.snp.left).offset(20)
            make.centerY.equalTo(parentView.snp.centerY)
        }
        
        sizeLabel.snp.makeConstraints { make in
            make.centerX.equalTo(parentView.snp.centerX)
            make.centerY.equalTo(parentView.snp.centerY)
        }
    
        return parentView
    }
}

extension SizePickerViewController: SizePickViewDelegate {
    func didTappedAddButton(selectedIndex: Int) {
        selectIndex(index: selectedIndex)
    }
}
