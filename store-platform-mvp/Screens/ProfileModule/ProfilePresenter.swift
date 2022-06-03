import Foundation

protocol ProfilePresenterProtocol {
    init(view: ProfileViewProtocol)
}

class ProfilePresenter: ProfilePresenterProtocol {
    var view: ProfileViewProtocol?
    
    required init(view: ProfileViewProtocol) {
        self.view = view
    }
}

