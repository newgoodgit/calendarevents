//
//  SGINAddAvailabilityViewControllerTest.swift
//  CalendarEntriesTests
//
//  Created by user on 12/24/20.
//  Copyright © 2020 Zirius. All rights reserved.
//

import XCTest
@testable import CalendarEntries

class SGINAddAvailabilityViewControllerTest: XCTestCase {
    
    var SGINAddAvailabilityVC = SGINAddAvailabilityViewController()
    
    /// testSGINAddAvailabilityViewController
    /// - Parameter param: nil
    /// - Returns: SignInViewController Intsatnce
    private func setUpViewControllers() {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        self.SGINAddAvailabilityVC = storyboard.instantiateViewController(withIdentifier: "SGINAddAvailabilityViewController") as! SGINAddAvailabilityViewController
        self.SGINAddAvailabilityVC.loadView()
        self.SGINAddAvailabilityVC.viewDidLoad()
    }
    
    override func setUp() {
        self.setUpViewControllers()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    /// ValidateViewControllerandIBOutlets
    /// - Parameter param: nil
    /// - Returns: nil
    func testMainVC() {
        XCTAssertNotNil(self.SGINAddAvailabilityVC, "Main VC is nil")
        XCTAssertNotNil(self.SGINAddAvailabilityVC.btnCancel, "btnCancel is nil")
        XCTAssertNotNil(self.SGINAddAvailabilityVC.btnAddAvailability, "btnAddAvailability is nil")
        XCTAssertNotNil(self.SGINAddAvailabilityVC.txtStartdate, "txtStartdate is nil")
        XCTAssertNotNil(self.SGINAddAvailabilityVC.txtView, "txtView is nil")
    }
    
    /// ValidateText
    /// - Parameter param: nil
    /// - Returns: nil
    func testValidateText() {
        self.SGINAddAvailabilityVC.txtStartdate?.text = ""
        self.SGINAddAvailabilityVC.txtView?.text = ""
        let validate = self.SGINAddAvailabilityVC.isValidationSuccess()
        XCTAssertTrue(validate == false)
        self.SGINAddAvailabilityVC.txtStartdate?.text = "newuser"
        self.SGINAddAvailabilityVC.txtView?.text = "1234567890"
        let validate1 = self.SGINAddAvailabilityVC.isValidationSuccess()
        XCTAssertTrue(validate1 == true)
        
    }
    
    /// GetDateFormat
    /// - Parameter param: nil
    /// - Returns: nil
    func testgetDateFormat() {
        let validate = self.SGINAddAvailabilityVC.getDateFormat(dateValue: Date())
        XCTAssertNotNil(validate)
    }
    
    /// Navigation
    /// - Parameter param: nil
    /// - Returns: nil
    func testTapOnAddAvailability() {
        self.SGINAddAvailabilityVC.txtStartdate?.text = "newuser"
        self.SGINAddAvailabilityVC.txtView?.text = "1234567890"
        let actions=self.SGINAddAvailabilityVC.btnAddAvailability.actions(forTarget: self.SGINAddAvailabilityVC, forControlEvent: UIControl.Event.touchUpInside)
        XCTAssertNotNil(actions, "AddAvailability Button should have conections")
        if actions != nil{
            guard let view = self.SGINAddAvailabilityVC.navigationController?.topViewController as? MonthViewController else {
                return
            }
            XCTAssertNotNil(view.calenderView, "Main VC is nil")
        }
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
