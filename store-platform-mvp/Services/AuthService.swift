import UIKit
import FirebaseAuth

enum AuthServiceError: Error {
    case signInError
    case createAccountError
    case logoutError
    case emptyFieldsError
}

protocol AuthServiceProtocol {
    func login(email: String?, password: String?, completion: @escaping (Result<User, AuthServiceError>) -> ())
    func register(email: String?, password: String?, completion: @escaping (Result<User, AuthServiceError>) -> ())
    func logout(completion: @escaping (AuthServiceError?) -> ())
}

final class AuthService: AuthServiceProtocol {
    static let sharedInstance = AuthService()
    private init() {}
    let auth = Auth.auth()
    
    func login(email: String?, password: String?, completion: @escaping (Result<User, AuthServiceError>) -> ()) {
        guard let email = email,
              let password = password else {
            completion(.failure(AuthServiceError.emptyFieldsError)); return
        }

        auth.signIn(withEmail: email, password: password) { result, error in
            guard let result = result else {
                completion(.failure(AuthServiceError.signInError)); return
            }
            
            let user = result.user
            completion(.success(user))
        }
    }
    
    func register(email: String?, password: String?, completion: @escaping (Result<User, AuthServiceError>) -> ()) {
        guard let email = email,
              let password = password else {
            completion(.failure(AuthServiceError.emptyFieldsError)); return
        }

        auth.createUser(withEmail: email, password: password) { result, error in
            guard let result = result else {
                return completion(.failure(AuthServiceError.createAccountError))
            }
            
            let user = result.user
            completion(.success(user))
        }
    }
    
    func logout(completion: @escaping (AuthServiceError?) -> ()) {
        do {
            try auth.signOut()
            completion(nil)
        } catch {
            completion(.logoutError)
        }
    }
}
