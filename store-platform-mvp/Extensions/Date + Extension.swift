import Foundation

// MARK: - Date Extension
extension Date {
    static let currentMonth: String = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        formatter.timeZone = .current
        formatter.locale = Locale(identifier: "en_GB")
        formatter.dateFormat = "MMM"
        
        let month = formatter.string(from: Date())
        return month
    }()
    
    static let currentDay: Int? = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        formatter.timeZone = .current
        formatter.locale = Locale(identifier: "en_GB")
        formatter.dateFormat = "d"
        
        if let day = Int(formatter.string(from: Date())) {
            return day
        }
        
        return nil 
    }()
}
