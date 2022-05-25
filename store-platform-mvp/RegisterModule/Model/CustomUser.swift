import Foundation

protocol CustomUserProtocol {
    var id: String? { get set }
    var firstName: String? { get set }
    var lastName: String? { get set }
    var email: String? { get set }
    func encodeUserInfo() -> [String: Any]
}

struct CustomUser: CustomUserProtocol {
    var id: String?
    var firstName: String?
    var lastName: String?
    var email: String?
    
    func encodeUserInfo() -> [String : Any] {
        let userInfo: [String : Any] = ["uid": id,
                                        "firstName": firstName,
                                        "lastName": lastName,
                                        "email": email]
        
        return userInfo
    }
}
