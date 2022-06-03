import UIKit

// MARK: - Categories, subcategories, colors, etc..
class ExtraSettingsCell: UICollectionViewCell {
    static let reuseId: String = "ExtraSettings"
    lazy var ellipseView: UIView = {
        let view = UIView()
        view.layer.borderWidth = 1.0
        view.layer.cornerRadius = 10
        view.layer.borderColor = UIColor.systemGray.cgColor
        return view
    }()
    
    lazy var label: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        label.textColor = .black
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(ellipseView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ExtraSettingsCell {
    func configure(category: String) {
        ellipseView.addSubview(label)
        
        ellipseView.snp.makeConstraints { make in
            make.edges.equalTo(snp.edges)
        }
        
        label.snp.makeConstraints { make in
            make.center.equalTo(snp.center)
        }
        
        label.text = category
    }
    
    func selectEllipse() {
        print(isSelected)
    
        if isSelected {
            ellipseView.backgroundColor = .black
            label.textColor = .white
        } else {
            ellipseView.backgroundColor = .white
            label.textColor = .black
        }
    }
}
