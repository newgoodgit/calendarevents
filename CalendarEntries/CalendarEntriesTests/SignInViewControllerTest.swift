//
//  SignInViewControllerTest.swift
//  CalendarEntriesTests
//
//  Created by user on 12/24/20.
//  Copyright © 2020 Zirius. All rights reserved.
//

import XCTest
@testable import CalendarEntries

class SignInViewControllerTest: XCTestCase {
    
    var signinVC = SignInViewController()
    
    
    /// testSignInViewController
    /// - Parameter param: nil
    /// - Returns: SignInViewController Intsatnce
    private func setUpViewControllers() {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        self.signinVC = storyboard.instantiateViewController(withIdentifier: "SignInViewController") as! SignInViewController
        self.signinVC.loadView()
        self.signinVC.viewDidLoad()
    }
    
    override func setUp() {
        self.setUpViewControllers()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    /// ValidateViewControllerandIBOutlets
    /// - Parameter param: nil
    /// - Returns: nil
    func testMainVC() {
        XCTAssertNotNil(self.signinVC, "Main VC is nil")
        XCTAssertNotNil(self.signinVC.loginButton, "loginButton is nil")
        XCTAssertNotNil(self.signinVC.keepMeLoggedInButton, "keepMeLoggedInButton is nil")
        XCTAssertNotNil(self.signinVC.usernameField, "usernameField is nil")
        XCTAssertNotNil(self.signinVC.passwordField, "passwordField is nil")
        XCTAssertNotNil(self.signinVC.havingTroubleLoginButton, "havingTroubleLoginButton is nil")
        XCTAssertNotNil(self.signinVC.btnPwd, "btnPwd is nil")
    }
    
    /// ValidateText
    /// - Parameter param: nil
    /// - Returns: nil
    func testValidateText() {
        let validate = self.signinVC.validate(emailId: "", password: "")
        if validate.0 == false {
            XCTAssertTrue(validate.1.count != 0)
        }else {
            XCTFail()
        }
        let validate1 = self.signinVC.validate(emailId: "newuser", password: "12345678")
        if validate1.0 == true {
            XCTAssertTrue(validate1.1.count == 0)
        }else {
            XCTFail()
        }
        
    }
    
    /// Navigation
    /// - Parameter param: nil
    /// - Returns: nil
    func testTapOnSignIn() {
        let actions=self.signinVC.loginButton.actions(forTarget: self.signinVC, forControlEvent: UIControl.Event.touchUpInside)
        XCTAssertNotNil(actions, "Login Button should have conections")
        if actions != nil{
            let validate1 = self.signinVC.validate(emailId: "newuser", password: "12345678")
            if validate1.0 == true {
                // Assert
                guard let view = self.signinVC.navigationController?.topViewController as? MonthViewController else {
                    return
                }
                XCTAssertNotNil(view.calenderView, "Main VC is nil")
            }else {
                XCTFail()
            }
        }
    }
    
    /// ValidatePasswordHide
    /// - Parameter param: nil
    /// - Returns: nil
    func testPasswordHideBtnAction() {
        self.signinVC.isPasswordHide = true
        self.signinVC.passwordHideShow(sender: UIButton())
        XCTAssertEqual(self.signinVC.btnPwd.imageView?.image, UIImage(named: "icon_eye_open"))
        
        self.signinVC.isPasswordHide = false
        self.signinVC.passwordHideShow(sender: UIButton())
        XCTAssertEqual(self.signinVC.btnPwd.imageView?.image, UIImage(named: "icon_eye_hide"))
        
    }
    
    
    /// ValidateKeepMeLogin
    /// - Parameter param: nil
    /// - Returns: nil
    func testKeepMeBtnAction() {
        
        self.signinVC.keepMeLoggedInButton.setImage(UIImage.init(named: "LoginChecked"), for: .normal)
        self.signinVC.keepMeLoggedInButtonClicked(UIButton())
        XCTAssertEqual(self.signinVC.keepMeLoggedInButton.imageView?.image, UIImage(named: "LoginUnChecked"))
        
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
