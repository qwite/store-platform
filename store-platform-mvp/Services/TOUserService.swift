import UIKit

protocol TOUserServiceProtocol: AnyObject {
}

class TOUserService: TOUserServiceProtocol {
    func getSellerStatus(completion: @escaping (Result<Bool, Error>) -> ()) {
        guard let userId = SettingsService.sharedInstance.userId else {
            return completion(.failure(UserServiceError.localUserNotExist))
        }
        FirestoreService.sharedInstance.getSellerStatus(userId: userId) { result in
            switch result {
            case .success(_):
                completion(.success(true))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

extension TOUserService {
    enum UserServiceError: Error {
        case someError
        case inputDataError
        case localUserNotExist
    }
}
