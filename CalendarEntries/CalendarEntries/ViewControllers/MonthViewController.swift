//
//  MonthViewController.swift
//  CalendarEntries
//
//  Created by user on 12/23/20.
//  Copyright © 2020 Zirius. All rights reserved.
//


import UIKit
import CoreData
import CoreFoundation

var eventDate: [DateResult] = []

class MonthViewController: UIViewController {
    
    @IBOutlet weak var refreshButton: UIButton!
    @IBOutlet weak var calenderView: CalendarView!
    @IBOutlet weak var btnAddAvailability: UIButton!
    @IBOutlet weak var tblMonthCalendarData: UITableView!
    @IBOutlet weak var btnMonthName: UIButton!
    @IBOutlet weak var btnLogout: UIButton!
    
    var calendarContext: NSManagedObjectContext!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var monthselectedDate = Date()
    var currentMonthselectedDate = Date().toLocalTime()
    var isCalendarLoad:Bool? = false
    var strAPISelectedDate:String? = ""
    
    // schedule list
    var scheduleListArray : [ScheduleListByDateResult] = []
    var isRefreshCalendar:Bool? = false
    var isRefreshLoading:Bool = false
    var isPuldownRefresh: Bool = false

    //paging
    var pageIndexVal : Double = 1
    var isPageEnable: Bool = true
    var isScroll: Bool = false
    //MARK:- Pull to Refresh Controller
    lazy var refreshControl: UIRefreshControl = {
        
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = UIColor.refreshCtrlColor()
        self.isRefreshLoading  = true
        
        refreshControl.addTarget(self, action: #selector(self.handleRefresh(_:)), for: UIControl.Event.valueChanged)
        return refreshControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.calendarImplement()
        self.initialLoad()
        //self.deleteCalendarEventData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.isCalendarLoad = false
        self.navigationController?.navigationBar.isHidden = true
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        self.loadCalendar()
    }
    
    @objc
    func handleRefresh(_ refreshControl: UIRefreshControl) {
        self.readCalendarEventData()
        self.refreshControl.endRefreshing()
    }
    
    func loadCalendar()  {
        if self.isRefreshCalendar! {
            self.calenderView.selectDate(self.monthselectedDate)
            self.calenderView.setDisplayDate(self.monthselectedDate)
            self.isRefreshCalendar = false
            self.isCalendarLoad = true
            self.getMonthEvents()
            return
        }
        self.isCalendarLoad = true
        let currentDate:Date? = Date().toLocalTime()
        self.strAPISelectedDate = self.getAPIDateFormat(dateValue:currentDate!)
        self.getScheduleListForDate()
        self.calenderView.setDisplayDate(currentDate!)
        self.calenderView.selectDate(currentDate!)
        self.calenderView.backgroundColor = UIColor.getAppLightBackgroundColor()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0) { // change 2 to desired number of seconds
            self.getMonthEvents()
            
        }
    }
    
    func initialLoad() {
        self.tblMonthCalendarData.delegate = self
        self.tblMonthCalendarData.dataSource = self
        self.tblMonthCalendarData.addSubview(self.refreshControl)
        
        self.tblMonthCalendarData.tableFooterView = UIView()
        self.tblMonthCalendarData?.register(UINib(nibName: "CalendarDataTableViewCell", bundle: nil), forCellReuseIdentifier: "CalendarDataTableViewCell")
        self.tblMonthCalendarData?.register(UINib(nibName: "WeekViewHeaderTableViewCell", bundle: nil), forCellReuseIdentifier: "WeekViewHeaderTableViewCell")
        self.tblMonthCalendarData?.register(UINib(nibName: "NoDataTableViewCell", bundle: nil), forCellReuseIdentifier: "NoDataTableViewCell")
        
        self.btnAddAvailability?.addTarget(self, action:#selector(self.btnAddAvailabilityTapped), for: .touchUpInside)
        
        
    }
    
    @IBAction func logoutButtonClicked(_ sender: Any) {
        
        let alert = UIAlertController(title:CONTENT_CALENDAR_TITLE , message: CONTENT_LOGOUT_MESSAGE, preferredStyle: UIAlertController.Style.alert)

        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: { (action: UIAlertAction!) in
                   
               }))
        alert.addAction(UIAlertAction(title: "Logout", style: UIAlertAction.Style.destructive, handler: { (action: UIAlertAction!) in
            self.navigationController?.popToRootViewController(animated: true)

        }))
        self.present(alert, animated: true, completion: nil)
    }
    
}

extension MonthViewController {
    
    func calendarImplement(){
        self.calendarLoad()
        let swipeFromRight = UISwipeGestureRecognizer(target: self, action: #selector(didSwipeLeft))
        swipeFromRight.direction = UISwipeGestureRecognizer.Direction.left
        self.calenderView.addGestureRecognizer(swipeFromRight)
        
        let swipeFromLeft = UISwipeGestureRecognizer(target: self, action: #selector(didSwipeRight))
        swipeFromLeft.direction = UISwipeGestureRecognizer.Direction.right
        self.calenderView.addGestureRecognizer(swipeFromLeft)
        self.calenderView.collectionView.isScrollEnabled = false
    }
    
    @objc func didSwipeLeft(gesture: UIGestureRecognizer) {
        self.moveNext()
    }
    
    @objc func didSwipeRight(gesture: UIGestureRecognizer) {
        self.movePrevious()
        
    }
    
    
    
    @objc func btnAddAvailabilityTapped(sender:UIButton)  {
        let initial = self.storyboard?.instantiateViewController(withIdentifier: "SGINAddAvailabilityViewController") as! SGINAddAvailabilityViewController
        self.isRefreshCalendar = true
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.pushViewController(initial, animated: true)
    }
    
    
    
    
    @IBAction func refreshButtonAction(_ sender: Any) {
        self.isRefreshCalendar = false
        self.loadCalendar()
        self.readCalendarEventData()
        self.showAlertbanner(message: CONTENT_CALENDAR_REFERSH, title:CONTENT_CALENDAR_TITLE, controller: self)
    }
    
    func getScheduleListForDate(){
        self.scheduleListArray.removeAll()
        self.tblMonthCalendarData.reloadData()
    }
    
    @objc func btnEditClicked(sender:UIButton)  {
        var scheduleData: ScheduleListByDateResult? = nil
        scheduleData = self.scheduleListArray[sender.tag - 2000]
        print(scheduleData?.eventsid as Any)
        self.editEventData(scheduleData: scheduleData!)
    }
    
    @objc func btnDeleteClicked(sender:UIButton)  {
        var scheduleData: ScheduleListByDateResult? = nil
        scheduleData = self.scheduleListArray[sender.tag - 1000]
        self.deleteCalendarEventID(eventID: scheduleData?.eventsid ?? "")
        self.refreshButtonAction(self.refreshButton ?? UIButton())
    }
    
    func editEventData(scheduleData:ScheduleListByDateResult)  {
        let initial = self.storyboard?.instantiateViewController(withIdentifier: "SGINAddAvailabilityViewController") as! SGINAddAvailabilityViewController
        initial.isEdit = true
        initial.isEventDescription = scheduleData.eventsdecs
        initial.isEventDate = scheduleData.eventsdate
        initial.isEventID = scheduleData.eventsid
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.pushViewController(initial, animated: true)
    }
    
}

// MARK: - Calendar View Methods
extension MonthViewController:CalendarViewDelegate,CalendarViewDataSource {
    
    func calendarLoad()  {
        CalendarView.Style.cellShape = .bevel(8.0)
        CalendarView.Style.cellColorDefault = UIColor.clear
        CalendarView.Style.cellColorToday = UIColor(red:1.00, green:0.84, blue:0.64, alpha:1.00)
        CalendarView.Style.cellBorderColor = UIColor(red:1.00, green:0.63, blue:0.24, alpha:1.00)
        CalendarView.Style.cellEventColor = UIColor.lightGray
        CalendarView.Style.headerTextColor = UIColor.white
        
        CalendarView.Style.cellTextColorDefault = UIColor.white
        CalendarView.Style.cellTextColorToday = UIColor.white
        CalendarView.Style.cellShape = .round
        calenderView.dataSource = self
        calenderView.delegate = self
        calenderView.direction = .horizontal
        calenderView.backgroundColor =  UIColor.darkGray
        
        calenderView.headerView.backgroundColor = UIColor.clear
        calenderView.headerView.layer.borderWidth = 1.0
        calenderView.headerView.layer.masksToBounds = true
        calenderView.headerView.layer.borderColor = UIColor.clear.cgColor
        
    }
    
    func movePrevious()  {
        self.calenderView.goToPreviousMonth()
    }
    
    func moveNext()  {
        self.calenderView.goToNextMonth()
    }
    
    func startDate() -> Date {
        var dateComponents = DateComponents()
        dateComponents.month = -25
        let today = Date()
        let threeMonthsAgo = self.calenderView.calendar.date(byAdding: dateComponents, to: today)!
        return threeMonthsAgo
    }
    
    func endDate() -> Date {
        var dateComponents = DateComponents()
        dateComponents.year = 80;
        let today = Date()
        let twoYearsFromNow = self.calenderView.calendar.date(byAdding: dateComponents, to: today)!
        return twoYearsFromNow
    }
    // MARK : KDCalendarDelegate
    func calendar(_ calendar: CalendarView, didSelectDate date : Date, withEvents events: [CalendarEvent]) {
        self.monthselectedDate = date
        if date.getMonthAndYear(date: date) == Date().getMonthAndYear(date: Date()){
            self.currentMonthselectedDate = date
        }
        self.strAPISelectedDate = self.getAPIDateFormat(dateValue:self.monthselectedDate)
        self.readCalendarEventData()
    }
    
    func calendar(_ calendar: CalendarView, didScrollToMonth date : Date) {
        if self.isCalendarLoad! {
            self.getMonthEvents()
            if date.getMonthAndYear(date: date) != Date().getMonthAndYear(date: Date()){
                self.calenderView.setDisplayDate(date)
                self.calenderView.selectDate(date)
            }else {
                self.currentMonthselectedDate = date
                self.calenderView.selectDate(date)
                self.calenderView.setDisplayDate(self.currentMonthselectedDate)
            }
        }
    }
    
    func calendar(_ calendar: CalendarView, sendMonthName: String) {
        if let index = (sendMonthName.range(of: ",")?.lowerBound) {
            _ = String(sendMonthName.prefix(upTo: index))
            let monthName = String(sendMonthName.prefix(upTo: index))
            let yearName = sendMonthName.components(separatedBy: ",").last
             self.btnMonthName?.setTitle(String(format: "%@ -%@", monthName.capitalizingFirstLetter(),yearName!), for: .normal)
        }
        
    }
}
extension MonthViewController {
    
    func getMonthEvents() {
        eventDate.removeAll()
        self.getMonthDotDetails()
    }
}

// MARK: - TableView Methods
extension MonthViewController: UITableViewDelegate,UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return  1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if self.scheduleListArray.count != 0 {
            return "Events data"
        }
        return "No data"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if self.scheduleListArray.count != 0 {
            return  self.scheduleListArray.count
        }
        return 1
        
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let headerView = view as? UITableViewHeaderFooterView {
            headerView.textLabel?.textAlignment = .center
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if self.scheduleListArray.count == 0 {
            let cell:NoDataTableViewCell =  self.tblMonthCalendarData?.dequeueReusableCell(withIdentifier: "NoDataTableViewCell", for: indexPath) as! NoDataTableViewCell
            cell.lblTitle?.text = "There is no calendar event!"
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
            cell.selectionStyle = .none
            return cell
        }else {
            let cell:CalendarDataTableViewCell =  self.tblMonthCalendarData?.dequeueReusableCell(withIdentifier: "CalendarDataTableViewCell", for: indexPath) as! CalendarDataTableViewCell
            self.setCellSetup(cell: cell, rowIndex: indexPath.row, scheduleArray: self.scheduleListArray, indexPath: indexPath)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
    }
    
    
    func getFontAttributes(color:UIColor) -> NSMutableAttributedString {
        let yourAttributes: [NSAttributedString.Key: Any] = [.foregroundColor:color, .font: UIFont(name: "Montserrat-Medium", size: 80)!]
        return NSMutableAttributedString(string: "•", attributes: yourAttributes)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func setCellSetup(cell:CalendarDataTableViewCell, rowIndex:Int, scheduleArray:[ScheduleListByDateResult], indexPath:IndexPath)  {
        if scheduleArray.count != 0 {
            let scheduleObj = scheduleArray[rowIndex]
            cell.rightSwipeConstantWidth.constant = 0
            cell.leftSwipeConstantIWidth.constant = 0
            cell.mainViewRightLeading.constant = 0
            cell.mainViewLeftTraling.constant = 0
            cell.addSwipeGestures()
            cell.leftBtn.tag = rowIndex + 2000
            cell.rightBtn.tag = rowIndex + 1000
            
            cell.leftBtn.addTarget(self, action: #selector(self.btnEditClicked(sender:)), for: .touchUpInside)
            cell.rightBtn.addTarget(self, action: #selector(self.btnDeleteClicked(sender:)), for: .touchUpInside)
            
            cell.selectionStyle = .none
            cell.layoutIfNeeded()
            cell.lblPositionName?.text = scheduleObj.eventsdate
            cell.lblDateTime?.text = scheduleObj.eventsdecs
        }
    }
    
    
}


// MARK: - UIScrollView Delegate

extension MonthViewController : UIScrollViewDelegate {
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        if scrollView.panGestureRecognizer.translation(in: scrollView).y < 0 {
            let currentOffset = scrollView.contentOffset.y
            let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
            if maximumOffset - currentOffset <= 10.0 {
                if (self.isPageEnable){
                    pageIndexVal = pageIndexVal + 1
                    self.isScroll = true
                }
            }
        }
    }
}
// MARK: Dots load methods
extension MonthViewController{
    
    func getMonthDotDetails(){
        
        self.calendarContext = appDelegate.persistentContainer.viewContext
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: TBL_CALENDAR_EVENT)
        do {
            let result = try self.calendarContext.fetch(fetch)
            for data in result as! [NSManagedObject] {
                let eventsdate = data.value(forKey: "eventsdate") as? String
                eventDate.append(DateResult.init(date: eventsdate, green: true))
            }
        } catch {
            print("Failed")
        }
        
        self.refreshUI()
    }
    
    func setUpPageIndex(){
        if self.pageIndexVal > 1 {
            self.pageIndexVal -= 1
        }
    }

    func refreshUI(){
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.calenderView.reloadData()
        }
        self.readCalendarEventData()
        
    }
    
    
    
    func readCalendarEventData()  {
        self.scheduleListArray.removeAll()
        self.calendarContext = appDelegate.persistentContainer.viewContext
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: TBL_CALENDAR_EVENT)
        let predicate = NSPredicate(format: "eventsdate == %@", self.strAPISelectedDate!)
        fetch.predicate = predicate
        do {
            let result = try self.calendarContext.fetch(fetch)
            for data in result as! [NSManagedObject] {
                let eventsid = data.value(forKey: "eventsid") as? String
                let eventsdate = data.value(forKey: "eventsdate") as? String
                let eventsdecs = data.value(forKey: "eventsdecs") as? String
                self.scheduleListArray.append(ScheduleListByDateResult.init(eventsid: eventsid, eventsdate: eventsdate, eventsdecs: eventsdecs))
            }
            self.tblMonthCalendarData?.reloadData()
        } catch {
            print("Failed")
        }
    }
    
    func deleteCalendarEventID(eventID:String)  {
        self.calendarContext = appDelegate.persistentContainer.viewContext
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: TBL_CALENDAR_EVENT)
        let predicate = NSPredicate(format: "eventsid == %@", eventID)
        fetch.predicate = predicate
        do {
            let result = try self.calendarContext.fetch(fetch)
            for data in result as! [NSManagedObject] {
                self.calendarContext.delete(data)
            }
            self.readCalendarEventData()
        } catch {
            print("Failed")
        }
    }
}

extension MonthViewController {
 
    func deleteCalendarEventData()  {
        let context = appDelegate.persistentContainer.viewContext
        let DelAllReqVar = NSBatchDeleteRequest(fetchRequest: NSFetchRequest<NSFetchRequestResult>(entityName: TBL_CALENDAR_EVENT))
        do {
            try context.execute(DelAllReqVar)
        }
        catch {
            print(error)
        }
    }
    
}





