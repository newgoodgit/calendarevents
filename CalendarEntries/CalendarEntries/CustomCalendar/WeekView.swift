//
//  WeekView.swift
//  WeekCalendarDemo
//
//  Created by Ducere on 24/05/17.
//  Copyright © 2017 Ducere. All rights reserved.
//

import UIKit

struct WeekViewCons {
    
    static let weekViewCount = 7
    static let dayTitleViewHeight = 60
    static let dayTitleTagInitialVal = 100
}

protocol WeekViewDelegate {
    func weekViewSelection(weekView : WeekView, didSelectedDate : Date)
    func weekViewSwipe(selectedDate : Date)
}

class WeekView: UIView {
    
    var monthNameLbl : UILabel!
    var dayInfoView : UIView!
    var weekStartDate : Date?
    var weekEndDate : Date?
    var tapSwipeSelectedDate = Date()
    var dayTextColor : UIColor?
    var monthPickerSelected:Bool = false
    var weekSelectedDate = Date()
    var initialPickerSelected:Bool = false
    
    var currentWeekDaysList : NSMutableArray = NSMutableArray()
    
    var delegate : WeekViewDelegate?
    
    var lightGrayColor : UIColor = {
        return UIColor.lightGray
    }()
    
    var dayFontFamily : UIFont? = {
        return UIFont(name: "OpenSans-Regular", size: 14)
    }()
    
    var monthFont : UIFont? = {
        return UIFont(name: "Raleway-Regular", size: 16)
    }()
    
    
    //MARK:- Initial View setup
    override init(frame : CGRect) {
        super.init(frame: frame)
        
        // self.addMothNameLable()
        //addDayInfoSubView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK:- Add Subviews
    func addMothNameLable() {
        
        monthNameLbl = UILabel(frame: CGRect(x: 0, y: 0, width: self.frame.size.width, height: 20))
        monthNameLbl.textAlignment = .center
        monthNameLbl.text = "July, 2017"
        monthNameLbl.font = monthFont
        monthNameLbl.textColor = UIColor.clear
        self.addSubview(monthNameLbl)
        
    }
    
    func addDayInfoSubView() {
        
        dayInfoView = UIView(frame: CGRect(x: 0, y: 0, width: self.frame.size.width, height: 40))
        self.addSubview(dayInfoView)
        
        let rightSwifeGesture = UISwipeGestureRecognizer(target: self, action: #selector(rightSwifeGestureAction(rightSwife:)))
        rightSwifeGesture.direction = .right
        self.addGestureRecognizer(rightSwifeGesture)

        let leftSwiftGesture = UISwipeGestureRecognizer(target: self, action: #selector(leftSwifeGestureAction(leftSwift:)))
        leftSwiftGesture.direction = .left
        self.addGestureRecognizer(leftSwiftGesture)
        
        // initDailyViews(date : Date)
        
        
    }
    
    func initDailyViews(date : Date) {
        
        let dayWidth : CGFloat = self.bounds.size.width/CGFloat(WeekViewCons.weekViewCount)

        weekStartDate = date.getWeekStartDate(fromDate: date)
        for view in self.dayInfoView.subviews {
            view.removeFromSuperview()
        }
        currentWeekDaysList.removeAllObjects()
        for i in 0..<WeekViewCons.weekViewCount {
            let nextDate = weekStartDate?.getNextDay(value: i, currentDate: weekStartDate)
            currentWeekDaysList.add(nextDate!)
            
            dayTitleViewForDate(date: nextDate, frame: CGRect(x: Int(dayWidth)*i, y: 0, width: Int(dayWidth), height: WeekViewCons.dayTitleViewHeight), tagVal: i)
        }
        
        monthNameLbl.text = weekStartDate?.getMonthAndYear(date: weekStartDate!)
    }
    
    func dayTitleViewForDate(date : Date?, frame : CGRect, tagVal : Int) {
        
        let currentDateLbl = UILabel(frame:frame)
        let dayLbl : UILabel = UILabel(frame: frame)
        dayLbl.backgroundColor = UIColor.clear
        dayLbl.textAlignment = .center
        dayLbl.font = dayFontFamily
        dayLbl.text =  "\((weekStartDate?.getDayNameFromDate(date: date!))!) " + "\n" + "\((weekStartDate?.dayOfWeek(date: date!))!)"
        dayLbl.textAlignment = .center
        dayLbl.numberOfLines = 0
        dayLbl.isUserInteractionEnabled = true
        dayLbl.tag = WeekViewCons.dayTitleTagInitialVal + tagVal
        dayLbl.textColor = UIColor.black
        
        let singleFingerTap = UITapGestureRecognizer(target: self, action: #selector(dayTitleViewDidClick(singleTap:)))
        
        let today = Date().toLocalTime()
        
        if self.monthPickerSelected == true{
            if self.checkFirstDateOfMonth(date: date!){
                self.tapSwipeSelectedDate = date!
                self.delegate?.weekViewSwipe(selectedDate: date ?? Date())
                self.monthPickerSelected = false
                dayLbl.textColor = UIColor.black
                dayLbl.backgroundColor = UIColor.white
            }
        }
        
        if ((weekStartDate?.fullDateToYear(date: date!))! == (weekStartDate?.fullDateToYear(date: today))!) {
            
            dayInfoView.addSubview(currentDateLbl)
            dayLbl.textColor = UIColor.red
            dayLbl.backgroundColor = UIColor.appThemeColor()
            dayLbl.addGestureRecognizer(singleFingerTap)
            
            
        } else  if (((weekStartDate?.fullDateToYear(date: date!))! > (weekStartDate?.fullDateToYear(date: today))!) && ((weekStartDate?.monthOfWeek(date: date!))!  >= (weekStartDate?.monthOfWeek(date: today))!)) || (((weekStartDate?.monthOfWeek(date: date!))!  > (weekStartDate?.monthOfWeek(date: today))!) && ((weekStartDate?.yearOfWeek(date: date!))!  >= (weekStartDate?.yearOfWeek(date: today))!)) {
            
            dayLbl.textColor = UIColor.black
            dayLbl.addGestureRecognizer(singleFingerTap)
        }
        else {
            
            dayLbl.addGestureRecognizer(singleFingerTap)
        }
        if self.initialPickerSelected == true {
            if ((weekStartDate?.fullDateToYear(date: date!))! == (weekStartDate?.fullDateToYear(date: tapSwipeSelectedDate))!)
            {
                dayLbl.textColor = UIColor.black
                dayLbl.backgroundColor = UIColor.white
            }
            
        }
        
        dayInfoView.addSubview(dayLbl)
        
    }
    
    
    //MARK:- Gestures
    @objc func dayTitleViewDidClick(singleTap : UITapGestureRecognizer) {
        
        var index = 0
        for view in self.dayInfoView.subviews {
            let anotherLbl : UILabel = view as! UILabel
            if anotherLbl.tag >= WeekViewCons.dayTitleTagInitialVal {
                anotherLbl.text =  "\((weekStartDate?.getDayNameFromDate(date: currentWeekDaysList[index] as! Date))!)" + "\n" + "\((weekStartDate?.dayOfWeek(date: currentWeekDaysList[index] as! Date))!)"
                let today = Date().toLocalTime()
                anotherLbl.textAlignment = .center
                anotherLbl.numberOfLines = 0
                anotherLbl.backgroundColor = UIColor.appThemeColor()
                anotherLbl.textColor = UIColor.black
                if ((weekStartDate?.fullDateToYear(date: currentWeekDaysList[index] as! Date))! == (weekStartDate?.fullDateToYear(date: today))!)  {
                    anotherLbl.textColor = UIColor.red
                    anotherLbl.backgroundColor = UIColor.appThemeColor()
                }
                index = index + 1
            }
        }
        
        let lbl : UILabel = singleTap.view as! UILabel
        lbl.backgroundColor = UIColor.white
        lbl.textColor = UIColor.black
        delegate?.weekViewSelection(weekView: self, didSelectedDate: currentWeekDaysList[lbl.tag - WeekViewCons.dayTitleTagInitialVal] as! Date)
    }
    
    @objc func rightSwifeGestureAction(rightSwife : UISwipeGestureRecognizer) {
        print("Right Swife")
        let checkDate = Calendar.current.date(byAdding: .day, value: -7, to: self.tapSwipeSelectedDate) ?? Date()
        var components = DateComponents()
        components.month = 12
        components.year = 2017
        components.day = 30
        components.calendar = Calendar.current
        if components.date! < checkDate {
            self.tapSwipeSelectedDate = Calendar.current.date(byAdding: .day, value: -7, to: self.tapSwipeSelectedDate) ?? Date()
            directionSwifeAnimation(isSwiftRight: true, isToday: false, selectedDate: nil)
            self.delegate?.weekViewSwipe(selectedDate: self.tapSwipeSelectedDate)
        }
        
    }
    
    @objc func leftSwifeGestureAction(leftSwift : UISwipeGestureRecognizer) {
        print("Left Swife")
        let checkDate = Calendar.current.date(byAdding: .day, value: 7, to: self.tapSwipeSelectedDate) ?? Date()
        var components = DateComponents()
        components.month = 12
        components.year = 2017
        components.day = 30
        components.calendar = Calendar.current
        if components.date! < checkDate {
            self.tapSwipeSelectedDate = Calendar.current.date(byAdding: .day, value: 7, to: self.tapSwipeSelectedDate) ?? Date()
            directionSwifeAnimation(isSwiftRight: false, isToday: false, selectedDate: nil)
            self.delegate?.weekViewSwipe(selectedDate: self.tapSwipeSelectedDate)
        }
        
    }

    
    func directionSwifeAnimation(isSwiftRight : Bool, isToday : Bool, selectedDate : Date?) {
        
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseInOut, animations: {
            if isSwiftRight == true {
                self.initPreviousOrNextViews(isNext: true)
                self.layoutIfNeeded()
            } else {
                self.initPreviousOrNextViews(isNext: false)
                self.layoutIfNeeded()
            }
        }) { (finished) in
        }
    }
    
    func initPreviousOrNextViews(isNext : Bool) {
        
        let dayWidth : CGFloat = self.bounds.size.width/CGFloat(WeekViewCons.weekViewCount)
        if !isNext {
            //weekEndDate = currentWeekDaysList.lastObject as? Date
            //weekStartDate = weekStartDate?.getPreviousOrNextWeek(weekDate: weekEndDate!, value: 1)
            weekEndDate = currentWeekDaysList.lastObject as? Date
            weekStartDate = Calendar.current.date(byAdding: .day, value: 1, to: weekEndDate ?? Date()) ?? Date()
        } else {
            //weekStartDate = weekStartDate?.getPreviousOrNextWeek(weekDate: weekStartDate!, value: -1)
            weekEndDate = currentWeekDaysList.firstObject as? Date
            weekStartDate = Calendar.current.date(byAdding: .day, value: -7, to: weekEndDate ?? Date()) ?? Date()
            
        }
        for view in self.dayInfoView.subviews {
            view.removeFromSuperview()
        }
        currentWeekDaysList.removeAllObjects()
        for i in 0..<WeekViewCons.weekViewCount {
            let nextDate = weekStartDate?.getNextDay(value: i, currentDate: weekStartDate)
            currentWeekDaysList.add(nextDate!)
            
            dayTitleViewForDate(date: nextDate, frame: CGRect(x: Int(dayWidth)*i, y: 0, width: Int(dayWidth), height: WeekViewCons.dayTitleViewHeight), tagVal: i)
        }
        monthNameLbl.text = weekStartDate?.getMonthAndYear(date: weekStartDate!)
    }
    
    func checkFirstDateOfMonth(date:Date) -> Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        var strOfDate:String = dateFormatter.string(from: date)
        strOfDate = String(strOfDate.prefix(2))
        if strOfDate == "01" {
            return true
        }
        return false
    }
}
