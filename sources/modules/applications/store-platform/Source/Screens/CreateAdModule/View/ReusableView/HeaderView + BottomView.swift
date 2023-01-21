import UIKit

// MARK: - BottomViewDelegate
protocol BottomViewDelegate: AnyObject {
    func didTappedAddProductButton()
}

// MARK: - HeaderView class
class HeaderView: UICollectionReusableView {
    static let reuseId: String = "Header"
    lazy var label = UILabel(text: nil,
                             font: UIFont.systemFont(ofSize: 18, weight: .medium),
                             textColor: .black)
    
    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension HeaderView {
    func configure() {
        addSubview(label)
        label.snp.makeConstraints { make in
            make.edges.equalTo(snp.edges)
        }
    }
}

//MARK: - BottomView class
class BottomViewWithButton: UICollectionReusableView {
    static let reuseId: String = "Bottom"
    weak var delegate: BottomViewDelegate?
    lazy var button = UIButton(text: "Добавить товар", preset: .bottom)
    
    
    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
        configureButtons()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        configureButtons()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension BottomViewWithButton {
    func configureView() {
        addSubview(button)
        button.snp.makeConstraints { make in
            make.top.equalTo(snp.top).offset(20)
            make.centerX.equalTo(snp.centerX)
            make.centerY.equalTo(snp.centerY)
            make.width.equalTo(160)
        }
    }
    
    func configureButtons() {
        button.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
    }
    
    @objc func addButtonTapped() {
        delegate?.didTappedAddProductButton()
    }
}
