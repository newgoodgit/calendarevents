//
//  WeekView+Extentions.swift
//  WeekCalendarDemo
//
//  Created by Ducere on 24/05/17.
//  Copyright © 2017 Ducere. All rights reserved.
//

import UIKit

class WeekView_Extentions: NSObject {
    
}


extension Date {
    
    
    var startOfWeek1: Date? {
        let gregorian = Calendar(identifier: .gregorian)
        guard let sunday = gregorian.date(from: gregorian.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)) else { return nil }
        return Calendar.current.date(byAdding: .day, value: 1, to: sunday)
        //return gregorian.date(byAdding: .day, value: 1, to: sunday)
    }
    
    func getWeekStartDate(fromDate : Date?) -> Date? {
        
        return fromDate?.startOfWeek1
        
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "yyyy-MM-dd"
//
//        if let date = fromDate {
//            var calendar = Calendar(identifier: .gregorian)
//            calendar.firstWeekday = 2
//            var startDate : Date = Date()
//            var interval : TimeInterval = 0
//
//            if calendar.dateInterval(of: .weekOfYear, start: &startDate, interval: &interval, for: date) {
//                print("Start of week is \(startDate)")
//                // prints "Start of week is 2017-01-01 06:00:00 +0000"
//                return startDate
//            }
//        }
//          return nil
    }
    
    func getNextDay(value : Int, currentDate : Date?) -> Date? {
        
        let dayComponenet = NSDateComponents()
        dayComponenet.day = value
        
        let theCalendar = NSCalendar.current
        let nextDate = theCalendar.date(byAdding: dayComponenet as DateComponents, to: currentDate!)
        return nextDate
        
    }
    
    func dayOfWeek(date : Date) -> Int {
        var calendar = Calendar.current
        calendar.timeZone = NSTimeZone(name: "UTC")! as TimeZone
        let day = calendar.component(.day, from: date)
        return day
    }
    
    func monthOfWeek(date : Date) -> Int {
        var calendar = Calendar.current
        calendar.timeZone = NSTimeZone(name: "UTC")! as TimeZone
        let month = calendar.component(.month, from: date)
        return month
    }
    
    func yearOfWeek(date : Date) -> Int {
        var calendar = Calendar.current
        calendar.timeZone = NSTimeZone(name: "UTC")! as TimeZone
        let year = calendar.component(.year, from: date)
        return year
    }
    
    func fullDateToYear(date : Date) -> (day : Int, month : Int, year : Int) {
        var calendar = Calendar.current
        calendar.timeZone = NSTimeZone(name: "UTC")! as TimeZone
        let day = calendar.component(.day, from: date)
        let month = calendar.component(.month, from: date)
        let year = calendar.component(.year, from: date)
        return (day, month, year)
    }
    
    func getMonthAndYear(date : Date) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM, yyyy"
        let newDate = dateFormatter.string(from: date)
        return newDate
        
    }
    
    func getDayNameFromDate(date : Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.dateFormat = "EE"
        let newDate = dateFormatter.string(from: date)
        return newDate
    }
    
    func getPreviousOrNextWeek(weekDate : Date, value : Int) -> Date? {
        
        let daysToAdd:Int = value
        // Set up date components
        let dateComponents: NSDateComponents = NSDateComponents()
        dateComponents.day = daysToAdd
        
        // Create a calendar
        let gregorianCalendar: NSCalendar = NSCalendar(identifier: NSCalendar.Identifier.gregorian)!
        let previousWeekEndDate: Date? = gregorianCalendar.date(byAdding: dateComponents as DateComponents, to: weekDate, options:NSCalendar.Options(rawValue: 0))!
        
        let weekStartDate = self.getWeekStartDate(fromDate: previousWeekEndDate)
        return weekStartDate
    }
}

