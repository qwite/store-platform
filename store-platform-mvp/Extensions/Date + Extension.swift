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
        
        guard let day = Int(formatter.string(from: Date())) else {
            return nil
        }
        
        return day
    }()
    
    static func dateWithTime(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        let time = formatter.string(from: date)
        formatter.dateFormat = "d MMM"
        formatter.locale = .current
        let date = formatter.string(from: date)
        
        return "\(date), \(time)"
    }
    
    static func parseDateString(date: String) -> String? {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        formatter.timeZone = .current
        formatter.locale = Locale(identifier: "en_GB")
        
        guard let fetchedDate = formatter.date(from: date) else {
            return nil
        }
        
        formatter.dateFormat = "d MMM"
        formatter.locale = .current
        let finalString = formatter.string(from: fetchedDate)
        
        return finalString
    }
    
    static func getFullDate(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        formatter.timeZone = .current
        formatter.locale = Locale(identifier: "en_GB")
        
        let dateString = formatter.string(from: date)
        return dateString
    }
    
    static func getFullDate(from string: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        formatter.timeZone = .current
        formatter.locale = Locale(identifier: "en_GB")
        
        guard let date = formatter.date(from: string) else {
            return nil
        }
        
        return date
    }
}
