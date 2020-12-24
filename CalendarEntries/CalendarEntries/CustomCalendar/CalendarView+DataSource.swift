/*
 * CalendarView+DataSource.swift
 * Created by Michael Michailidis on 24/10/2017.
 * http://blog.karmadust.com/
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 */

import UIKit
import CoreText

extension CalendarView: UICollectionViewDataSource {
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        guard let dateSource = self.dataSource else { return 0 }
        
        self.startDateCache = dateSource.startDate()
        self.endDateCache   = dateSource.endDate()
        
        guard self.startDateCache <= self.endDateCache else { fatalError("Start date cannot be later than end date.") }
        
        var firstDayOfStartMonth = self.calendar.dateComponents([.era, .year, .month], from: startDateCache)
        firstDayOfStartMonth.day = 1
        
        let dateFromDayOneComponents = self.calendar.date(from: firstDayOfStartMonth)!
        self.startOfMonthCache = dateFromDayOneComponents
        let currentDate:Date? = Date().toLocalTime()
        if (self.startOfMonthCache ... self.endDateCache).contains(currentDate!) {
            
            let distanceFromTodayComponents = self.calendar.dateComponents([.month, .day], from: self.startOfMonthCache, to: currentDate!)
            
            self.todayIndexPath = IndexPath(item: distanceFromTodayComponents.day!, section: distanceFromTodayComponents.month!)
        }
        
        // if we are for example on the same month and the difference is 0 we still need 1 to display it
        return self.calendar.dateComponents([.month], from: startDateCache, to: endDateCache).month! + 1
    }
    
    public func getMonthInfo(for date: Date) -> (firstDay: Int, daysTotal: Int)? {
        
        var firstWeekdayOfMonthIndex    = self.calendar.component(.weekday, from: date)
        //firstWeekdayOfMonthIndex        = firstWeekdayOfMonthIndex // firstWeekdayOfMonthIndex should be 0-Indexed
        firstWeekdayOfMonthIndex        = (firstWeekdayOfMonthIndex + 6) % 7 // push it modularly to take it back one day where the first day is Monday instead of Sunday
        
        guard let rangeOfDaysInMonth:Range<Int> = self.calendar.range(of: .day, in: .month, for: date) else { return nil }
        
        // the format of the range returned is (1..<32) so subtract the lower to get the absolute
        let numberOfDaysInMonth         = rangeOfDaysInMonth.upperBound - rangeOfDaysInMonth.lowerBound
        
        return (firstDay: firstWeekdayOfMonthIndex, daysTotal: numberOfDaysInMonth)
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        var monthOffsetComponents = DateComponents()
        monthOffsetComponents.month = section;
        
        guard
            let correctMonthForSectionDate = self.calendar.date(byAdding: monthOffsetComponents, to: startOfMonthCache),
            let info = self.getMonthInfo(for: correctMonthForSectionDate) else { return 0 }
        
        self.monthInfoForSection[section] = info
        
        return 42 // 7 x 6
        
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let dayCell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseIdentifier, for: indexPath) as! CalendarDayCell
        
        // let getDate1 = self.dateFromIndexPath(indexPath)
        
        guard let (firstDayIndex, numberOfDaysTotal) = self.monthInfoForSection[indexPath.section]
            else {
                return dayCell
        }
        
        let fromStartOfMonthIndexPath = IndexPath(item: indexPath.item - firstDayIndex, section: indexPath.section) // if the first is wednesday, add 2
        let lastDayIndex = firstDayIndex + numberOfDaysTotal
        
        dayCell.dotsViewOne.attributedText = nil
        if (firstDayIndex..<lastDayIndex).contains(indexPath.item) { // item within range from first to last day
            
            dayCell.textLabel.text = String(fromStartOfMonthIndexPath.item + 1)
            dayCell.dotsViewOne.isHidden = true
            
            dayCell.isHidden = false
            let getDate = self.dateFromIndexPath(indexPath)
            let dateFormatter = DateFormatter()
            dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
            dateFormatter.dateFormat = "dd-MMM-yyyy"
            let dateString = dateFormatter.string(from: getDate!)
            for i in 0 ..< eventDate.count {
                var dateValue:String? = ""
                dateValue = eventDate[i].date
                if dateString == dateValue {
                    dayCell.eventsCount = fromStartOfMonthIndexPath.item + 1
                    dayCell.isSelected = selectedIndexPaths.contains(indexPath)
                    if indexPath.section == 0 && indexPath.item == 0 {
                        self.scrollViewDidEndDecelerating(collectionView)
                    }
                    if let idx = todayIndexPath {
                        dayCell.isToday = (idx.section == indexPath.section && idx.item + firstDayIndex == indexPath.item)
                    }
                    _ = eventDate[i]
                    let dotStr = NSMutableAttributedString()
                    let yourAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.red, .font: UIFont.systemFont(ofSize: 25)]
                    let partOne = NSMutableAttributedString(string: "•", attributes: yourAttributes)
                    dotStr.append(partOne)
                    dayCell.dotsViewOne.isHidden = false
                    DispatchQueue.main.async {
                        dayCell.dotsViewOne.attributedText = dotStr
                    }
                    return dayCell
                    
                }else{
                    dayCell.eventsCount = 0
                }
            }
        }
        else {
            dayCell.textLabel.text = ""
            dayCell.isHidden = true
        }
        dayCell.isSelected = selectedIndexPaths.contains(indexPath)
        if indexPath.section == 0 && indexPath.item == 0 {
            self.scrollViewDidEndDecelerating(collectionView)
        }
        if let idx = todayIndexPath {
            dayCell.isToday = (idx.section == indexPath.section && idx.item + firstDayIndex == indexPath.item)
        }
        return dayCell
    }
}

extension Date {
    
    // Convert local time to UTC (or GMT)
    func toGlobalTime() -> Date {
        let timezone = TimeZone.current
        let seconds = -TimeInterval(timezone.secondsFromGMT(for: self))
        return Date(timeInterval: seconds, since: self)
    }
    
    // Convert UTC (or GMT) to local time
    func toLocalTime() -> Date {
        let timezone = TimeZone.current
        let seconds = TimeInterval(timezone.secondsFromGMT(for: self))
        return Date(timeInterval: seconds, since: self)
    }
    func dayOfWeek() -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        return dateFormatter.string(from: self).capitalized
        // or use capitalized(with: locale) if you want
    }
    
    func startOfMonth(dateVal:Date?) -> Date {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(identifier:"UTC")!
        let currentDateComponents = calendar.dateComponents([.year, .month], from: self)
        let startOfMonth = calendar.date(from: currentDateComponents)
        return startOfMonth!
    }
}
