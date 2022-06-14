import Foundation

class SettingsService {
    static let sharedInstance = SettingsService()
    private init() {}
    
    var isAuthorized: Bool {
        get {
            let value = UserDefaults.standard.bool(forKey: "isAuthorized")
            return value
        }
        set (value) {
            UserDefaults.standard.set(value, forKey: "isAuthorized")
        }
    }
    
    var userId: String? {
        get {
            guard let value = UserDefaults.standard.string(forKey: "userId") else {
                return nil
            }
            
            return value
        }
        set (value) {
            guard let value = value else {
                return UserDefaults.standard.set(nil, forKey: "userId")

            }
            
            UserDefaults.standard.set(value, forKey: "userId")
        }
    }
    
    var userFullName: [String: String]? {
        get {
            guard let value = UserDefaults.standard.dictionary(forKey: "userFullName") as? [String: String] else {
                return nil
            }
            
            return value
        }
        
        set (value) {
            guard let value = value else {
                return UserDefaults.standard.set(nil, forKey: "userFullName")
            }
            
            UserDefaults.standard.set(value, forKey: "userFullName")
        }
    }
    
    var brandName: String? {
        get {
            guard let value = UserDefaults.standard.string(forKey: "brandName") else {
                return nil
            }
            
            return value
        }
        set (value) {
            guard let value = value else {
                return UserDefaults.standard.set(nil, forKey: "brandName")
            }
            
            UserDefaults.standard.set(value, forKey: "brandName")
        }
    }
}
