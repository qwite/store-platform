import UIKit

// MARK: - RadioButtonDelegate
protocol RadioButtonDelegate: AnyObject {
    func didButtonPressed(_ sender: UIView)
}

// MARK: - RadioButton
class RadioButton: UIButton {
    private var normalView = UIImageView(image: UIImage(named: "button_unselected"))
    private var selectedView: UIView =  UIImageView(image: UIImage(named: "button_selected"))
    var type: RadioButtonType?
    
    weak var delegate: RadioButtonDelegate?
    
    var isChecked: Bool = false {
        didSet {
            setNeedsLayout()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        normalView.removeFromSuperview()
        selectedView.removeFromSuperview()

        guard let titleView = self.titleLabel else {
            return
        }
        
        titleView.snp.makeConstraints { make in
            make.left.equalTo(self.snp.left)
        }
        
        self.snp.makeConstraints { make in
            make.width.equalTo(snp.width)
            make.height.equalTo(20)
        }
        
        let view = isChecked ? selectedView : normalView
        
        self.addSubview(view)
       
        view.snp.makeConstraints { make in
            make.height.equalTo(15)
            make.width.equalTo(15)
            make.centerY.equalTo(self.snp.centerY)
            make.right.equalTo(self.snp.right)
        }
    }
    
    @objc private func buttonPressed() {
        delegate?.didButtonPressed(_: self)
    }
}

// MARK: - RadioButtonType
extension RadioButton {
    enum RadioButtonType {
        case newItems
        case popularItems
        case byIncreasingPrice
        case byDecreasingPrice
    }
}
