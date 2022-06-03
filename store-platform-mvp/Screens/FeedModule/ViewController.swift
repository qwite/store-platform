import UIKit

class ViewController: UIViewController {
    var presenter: MainPresenter!
    
    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Name"
        return label
    }()
    
    lazy var lastNameLabel: UILabel = {
        let label = UILabel()
        label.text = "Last Name"
        return label
    }()
    
    lazy var button: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Push", for: .normal)
        button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        let stack = UIStackView(arrangedSubviews: [nameLabel, lastNameLabel, button])
        stack.axis = .vertical
        stack.alignment = .center
        stack.distribution = .fill
        stack.spacing = 5
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stack)
        stack.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        stack.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    @objc func buttonAction() {
        presenter.showCreditionals()
    }
}

extension ViewController: MainViewProtocol {
    func setCreditionals(name: String, lastName: String) {
        self.nameLabel.text = name
        self.lastNameLabel.text = lastName
    }
}
