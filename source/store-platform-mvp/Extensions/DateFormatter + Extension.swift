import UIKit

extension DateFormatter {
    static let fullDateMedium: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .medium
        df.timeZone = .current
        df.locale = Locale(identifier: "en_GB")
        
        return df
    }()
    
    static let monthMedium: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .medium
        df.timeZone = .current
        df.locale = Locale(identifier: "en_GB")
        df.dateFormat = "MMM"
        
        return df
    }()
    
    static let dayMedium: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .medium
        df.timeZone = .current
        df.locale = Locale(identifier: "en_GB")
        df.dateFormat = "d"
        
        return df
    }()
    
    static let dayWithMonth: DateFormatter = {
        let df = DateFormatter()
        df.locale = .current
        df.dateFormat = "d MMM"
        
        return df
    }()
    
    static let time: DateFormatter = {
        let df = DateFormatter()
        df.locale = .current
        df.dateFormat = "HH:mm"
        
        return df
    }()
    
    static func getMonth(from date: Date = Date()) -> String {
        return DateFormatter.monthMedium.string(from: date)
    }
    
    static func getDayWithMonth(from date: Date = Date()) -> String {
        return DateFormatter.dayWithMonth.string(from: date)
    }
    
    static func getDayWithMonth(from date: String) -> String? {
        guard let fullDate = DateFormatter.getFullDate(from: date) else {
            return nil
        }
        
        let dayWithMonth = DateFormatter.getDayWithMonth(from: fullDate)
        return dayWithMonth
    }
     
    static func getDay(from date: Date = Date()) -> Int? {
        let stringDay = DateFormatter.dayMedium.string(from: date)
        guard let intDay = Int(stringDay) else {
            return nil
        }
        
        return intDay
    }
    
    static func getTime(from date: Date = Date()) -> String {
        return DateFormatter.time.string(from: date)
    }
    
    static func getTime(from date: String) -> String? {
        // Getting full date from string
        guard let fullDate = DateFormatter.getFullDate(from: date) else {
            return nil
        }
        
        // Convert it to string time
        let time = DateFormatter.getTime(from: fullDate)
        return time
    }
    
    static func getFullDate(from date: Date = Date()) -> String {
        return DateFormatter.fullDateMedium.string(from: date)
    }
    
    static func getFullDate(from date: String) -> Date? {
        guard let date = DateFormatter.fullDateMedium.date(from: date) else {
            return nil
        }
        
        return date
    }
}
