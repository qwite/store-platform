import Foundation

protocol MainViewProtocol: AnyObject {
    func setCreditionals(name: String, lastName: String)
}

protocol MainViewPresenterProtocol: AnyObject {
    init(view: MainViewProtocol, model: Human)
    func showCreditionals()
}

class MainPresenter: MainViewPresenterProtocol {
    let view: MainViewProtocol
    let model: Human
    
    required init(view: MainViewProtocol, model: Human) {
        self.view = view
        self.model = model
    }
    
    func showCreditionals() {
        view.setCreditionals(name: model.name, lastName: model.lastName)
    }
}
