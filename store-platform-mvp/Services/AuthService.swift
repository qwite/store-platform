import UIKit
import FirebaseAuth

enum AuthServiceError: Error {
    case signInError
    case createAccountError
    case unwrapError
}

protocol AuthServiceProtocol {
    func login(email: String?, password: String?, completion: @escaping (Result<User, Error>) -> ())
    func register(email: String?, password: String?, completion: @escaping (Result<User, Error>) -> ())
}

class AuthService: AuthServiceProtocol {
    static let sharedInstance = AuthService()
    private init() {}
    let auth = Auth.auth()
    
    func login(email: String?, password: String?, completion: @escaping (Result<User, Error>) -> ()) {
        guard let email = email,
              let password = password else {
                  return completion(.failure(AuthServiceError.unwrapError))
              }

        auth.signIn(withEmail: email, password: password) { result, error in
            guard let result = result else {
                return completion(.failure(AuthServiceError.signInError))
            }
            
            let user = result.user
            completion(.success(user))
        }
    }
    
    func register(email: String?, password: String?, completion: @escaping (Result<User, Error>) -> ()) {
        guard let email = email,
              let password = password else {
                  return completion(.failure(AuthServiceError.unwrapError))
        }

        auth.createUser(withEmail: email, password: password) { result, error in
            guard let result = result else {
                return completion(.failure(AuthServiceError.createAccountError))
            }
            
            let user = result.user
            completion(.success(user))
        }
    }
}
