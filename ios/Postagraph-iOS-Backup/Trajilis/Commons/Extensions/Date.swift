//
//  Date.swift
//  Trajilis
//
//  Created by Moses on 29/11/2018.
//  Copyright © 2018 Johnson. All rights reserved.
//

import Foundation

extension Date {
    
    // return all dates in a range excluding start and end dates.
    static func dates(from fromDate: Date, to toDate: Date, in calendar: Calendar) -> [Date] {
        var dates: [Date] = []
        var date = fromDate
        
        while date < toDate {
            dates.append(date)
            guard let newDate = calendar.date(byAdding: .day, value: 1, to: date) else { break }
            date = newDate
        }
        return dates
    }

    // return all dates in a range including start and end dates.
    static func datesInRange(from fromDate: Date, to toDate: Date, in calendar: Calendar) -> [Date] {
        var dates: [Date] = []
        var date = fromDate
        
        while date < toDate {
            dates.append(date)
            guard let newDate = calendar.date(byAdding: .day, value: 1, to: date) else { break }
            date = newDate
        }
        return dates
    }
    
    var isFuture: Bool {
        let today = Date()
        return today.timeIntervalSince1970 < self.timeIntervalSince1970
        
//        let component1 =
//        print(self > today)
//        print(self < today)
//
//        return self >= today
        
//        let components1: DateComponents = NSCalendar.current.dateComponents([.year, .month, .day], from: self)
//        let components2 = NSCalendar.current.dateComponents([.year, .month, .day], from: today)
//        return (components1.year! >= components2.year!) || (components1.month! >= components2.month!) || (components1.day! >= components2.day!)
    }
    public func toString(dateFormat: String = "EEEE dd MMMM yyyy hh mm a", dateStyle: DateFormatter.Style = .full) -> String{
        let dateFormatter = DateFormatter()
        if !dateFormat.isEmpty {
            dateFormatter.dateFormat = dateFormat
        }else {
            dateFormatter.dateStyle = dateStyle
        }
        let date = dateFormatter.string(from: self)
        return date
    }
 
    public func getStringInformat(dateFormat: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        return formatter.string(from:self)
    }

    public func dateByAddingDays(days:Int) -> Date? {
        return Calendar.current.date(byAdding: .day, value: days, to: self)
    }
    
    func offsetFrom(date : Date) -> String {
        
        let dayHourMinuteSecond: Set<Calendar.Component> = [.day, .hour, .minute, .second]
        let difference = NSCalendar.current.dateComponents(dayHourMinuteSecond, from: date, to: self);
        
        //let seconds = "\(difference.second ?? 0)s"
        let minutes = "\(difference.minute ?? 0)m"
        let hours = "\(difference.hour ?? 0)h" + " " + minutes
        let days = "\(difference.day ?? 0)d" + " " + hours
        
        if let day = difference.day, day          > 0 { return days }
        if let hour = difference.hour, hour       > 0 { return hours }
        if let minute = difference.minute, minute > 0 { return minutes }
        //if let second = difference.second, second > 0 { return seconds }
        return ""
    }
}
