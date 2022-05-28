import UIKit

protocol FavoritesViewProtocol {
    
}

class FavoritesViewController: UIViewController {
    var presenter: FavoritesPresenter!
    lazy var label = UILabel(text: "Избранное", font: UIFont.systemFont(ofSize: 14, weight: .regular), textColor: .black)
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.center.equalTo(view.snp.center)
        }
    }
}

extension FavoritesViewController: FavoritesViewProtocol {
    
}

