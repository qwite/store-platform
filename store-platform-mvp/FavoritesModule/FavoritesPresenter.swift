import Foundation

protocol FavoritesPresenterProtocol {
    init(view: FavoritesViewProtocol)
}

class FavoritesPresenter: FavoritesPresenterProtocol {
    var view: FavoritesViewProtocol
    
    required init(view: FavoritesViewProtocol) {
        self.view = view
    }
}

