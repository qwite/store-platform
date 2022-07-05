import UIKit

enum Constants {
    enum Fonts {
        static let mainTitleFont = UIFont.systemFont(ofSize: 30, weight: .heavy)
        static let itemTitleFont = UIFont.systemFont(ofSize: 17, weight: .semibold)
        static let itemDescriptionFont = UIFont.systemFont(ofSize: 14, weight: .light)
    }
    
    enum Messages {
        static let successUserLogin = "Успешная авторизация!"
    }
    
    enum Errors {
        static let emptyFieldsError = "Некорректно заполнены поля"
        static let loginError = "Произошла ошибка при авторизации"
        static let registerError = "Произошла ошибка при регистрации"
        static let logoutError = "Произошла ошибка при выходе из аккаунта"
        static let unknownError = "Неизвестная ошибка"
    }
}
