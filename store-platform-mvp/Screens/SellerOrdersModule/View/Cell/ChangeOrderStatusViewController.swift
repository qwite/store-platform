import UIKit

protocol ChangeOrderStatusViewProtocol: AnyObject {
    func configure()
    func configureButtons()
}

class ChangeOrderStatusViewController: UIViewController {
    var presenter: ChangeOrderStatusPresenterProtocol!
    var changeOrderView = ChangeOrderStatusView()
    @objc var preferredHeightInBottomSheet: CGFloat { return 380 }
    override func loadView() {
        view = changeOrderView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewDidLoad()
    }
}

extension ChangeOrderStatusViewController: ChangeOrderStatusViewProtocol {
    func configure() {
        changeOrderView.configureViews()
        changeOrderView.pickerView.dataSource = self
        changeOrderView.pickerView.delegate = self
    }
    
    func configureButtons() {
        changeOrderView.button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
    }
    
    @objc private func buttonAction() {
        let status = presenter.getAvailableStatus()
        let selected = changeOrderView.pickerView.selectedRow(inComponent: 0)
        presenter.changeStatus(status: status[selected])
    }
}

extension ChangeOrderStatusViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 3
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let status = presenter.getAvailableStatus()
        
        let pickerLabel = (view as? UILabel) ?? UILabel()
        
        pickerLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        pickerLabel.text = status[row]
        pickerLabel.textAlignment = .center
        
        return pickerLabel
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 44.0
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return view.bounds.size.width
    }
    
    
}
