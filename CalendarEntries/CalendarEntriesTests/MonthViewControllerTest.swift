//
//  MonthViewControllerTest.swift
//  CalendarEntriesTests
//
//  Created by user on 12/24/20.
//  Copyright © 2020 Zirius. All rights reserved.
//

import XCTest
import CoreData
import CoreFoundation
@testable import CalendarEntries

class MonthViewControllerTest: XCTestCase {
    
    var MonthVC = MonthViewController()
    
    /// testSGINAddAvailabilityViewController
    /// - Parameter param: nil
    /// - Returns: SignInViewController Intsatnce
    private func setUpViewControllers() {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        self.MonthVC = storyboard.instantiateViewController(withIdentifier: "MonthViewController") as! MonthViewController
        self.MonthVC.loadView()
        self.MonthVC.viewDidLoad()
    }
    
    override func setUp() {
        self.setUpViewControllers()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    /// ValidateViewControllerandIBOutlets
    /// - Parameter param: nil
    /// - Returns: nil
    func testMainVC() {
        XCTAssertNotNil(self.MonthVC, "Main VC is nil")
        XCTAssertNotNil(self.MonthVC.refreshButton, "refreshButton is nil")
        XCTAssertNotNil(self.MonthVC.calenderView, "calenderView is nil")
        XCTAssertNotNil(self.MonthVC.btnAddAvailability, "btnAddAvailability is nil")
        XCTAssertNotNil(self.MonthVC.tblMonthCalendarData, "tblMonthCalendarData is nil")
        XCTAssertNotNil(self.MonthVC.btnMonthName, "tblMonthCalendarData is nil")
        XCTAssertNotNil(self.MonthVC.btnLogout, "tblMonthCalendarData is nil")
    }
        
    /// Navigation
    /// - Parameter param: nil
    /// - Returns: nil
    func testTapOnAddAvailability() {

        let actions=self.MonthVC.btnAddAvailability.actions(forTarget: self.MonthVC, forControlEvent: UIControl.Event.touchUpInside)
        XCTAssertNotNil(actions, "AddAvailability Button should have conections")
        if actions != nil{
            guard let view = self.MonthVC.navigationController?.topViewController as? SGINAddAvailabilityViewController else {
                return
            }
            XCTAssertNotNil(view.btnAddAvailability, "Main VC is nil")
        }
    }
    
    
    /// ValidateTableView
    /// - Parameter param: nil
    /// - Returns: nil
    func testHasATableView() {
        XCTAssertNotNil(self.MonthVC.tblMonthCalendarData)
    }
    
    /// ValidateTableViewDelegate
    /// - Parameter param: nil
    /// - Returns: nil
    func testTableViewHasDelegate() {
        XCTAssertNotNil(self.MonthVC.tblMonthCalendarData.delegate)
    }
    
    /// ValidateTableViewDelegateProtocol
    /// - Parameter param: nil
    /// - Returns: nil
    func testTableViewConfromsToTableViewDelegateProtocol() {
        //XCTAssertTrue(self.indoorsFloorsVC.tableFloors.conforms(to: UITableViewDelegate.self))
        
        XCTAssertTrue(self.MonthVC.responds(to: #selector(self.MonthVC.tableView(_:didSelectRowAt:))))
    }
    
    /// ValidateTableViewDataSource
    /// - Parameter param: nil
    /// - Returns:  nil
    func testTableViewHasDataSource() {
        XCTAssertNotNil(self.MonthVC.tblMonthCalendarData.dataSource)
    }
    
    /// ValidateTableViewDataSourceProtocol
    /// - Parameter param: nil
    /// - Returns: nil
    func testTableViewConformsToTableViewDataSourceProtocol() {
        XCTAssertTrue(self.MonthVC.conforms(to: UITableViewDataSource.self))
        XCTAssertTrue(self.MonthVC.responds(to: #selector(self.MonthVC.tableView(_:numberOfRowsInSection:))))
        XCTAssertTrue(self.MonthVC.responds(to: #selector(self.MonthVC.tableView(_:cellForRowAt:))))
    }
    
    /// ValidateTableViewCellHasReuseIdentifier
    /// - Parameter param: nil
    /// - Returns: nil
    func testTableViewCellHasReuseIdentifier() {
        self.MonthVC.scheduleListArray.append(ScheduleListByDateResult.init(eventsid: "231523145", eventsdate: "24-Dec-2020", eventsdecs: "newgoodevent"))
        self.MonthVC.tblMonthCalendarData?.reloadData()
        let cell = self.MonthVC.tableView(self.MonthVC.tblMonthCalendarData, cellForRowAt: IndexPath(row: 0, section: 0)) as? CalendarDataTableViewCell
        let actualReuseIdentifer = cell?.reuseIdentifier
        let expectedReuseIdentifier = "CalendarDataTableViewCell"
        XCTAssertEqual(actualReuseIdentifer, expectedReuseIdentifier)
    }
    
    /// ValidateTableViewCell
    /// - Parameter param: nil
    /// - Description: Testing the table view cell
    func testTableViewCell() {
        
       self.MonthVC.scheduleListArray.append(ScheduleListByDateResult.init(eventsid: "231523145", eventsdate: "24-Dec-2020", eventsdecs: "newgoodevent"))
        self.MonthVC.tblMonthCalendarData?.reloadData()
        let cell = self.MonthVC.tableView(self.MonthVC.tblMonthCalendarData, cellForRowAt: IndexPath(row: 0, section: 0)) as? CalendarDataTableViewCell
        XCTAssertNotNil(cell)
        XCTAssertTrue(((cell) != nil))
        let visibleRows = self.MonthVC.tblMonthCalendarData?.indexPathsForVisibleRows
        XCTAssertNotNil(visibleRows)
        XCTAssertTrue(self.MonthVC.tblMonthCalendarData?.indexPathsForVisibleRows!.contains(IndexPath(row: 0, section: 0)) == true)
    }
    
    func dbInsertUpadteDelete()  {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: TBL_CALENDAR_EVENT, in: context)
        let newCalendar = NSManagedObject(entity: entity!, insertInto: context)
        newCalendar.setValue(String(format: "%@", "325135eqq"), forKey: "eventsid")
        newCalendar.setValue("23-Dec-2020", forKey: "eventsdate")
        newCalendar.setValue("New Event", forKey: "eventsdecs")
        do {
           try context.save()
            
          } catch {
           print("Failed saving")
        }
        self.MonthVC.scheduleListArray.removeAll()
        XCTAssertTrue(self.MonthVC.scheduleListArray.count == 0)
        self.MonthVC.readCalendarEventData()
        XCTAssertTrue(self.MonthVC.scheduleListArray.count != 0)
        self.MonthVC.deleteCalendarEventID(eventID: "325135eqq")
        XCTAssertTrue(self.MonthVC.scheduleListArray.count == 0)
    }
    
    /// ReadCalendarEventData
    /// - Parameter param: nil
    /// - Description: Testing the table view cell
    func testreadCalendarEventData() {
       self.MonthVC.readCalendarEventData()
       XCTAssertNotNil(self.MonthVC.scheduleListArray)
    }
        
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}

