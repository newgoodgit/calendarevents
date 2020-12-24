//
//  SignInViewController.swift
//  CalendarEntries
//
//  Created by user on 12/23/20.
//  Copyright © 2020 Zirius. All rights reserved.
//

import UIKit



class SignInViewController: UIViewController {

    //MARK: outlets
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var keepMeLoggedInButton: UIButton!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var havingTroubleLoginButton: UIButton!
    @IBOutlet weak var btnPwd: UIButton!

    var isPasswordHide: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.initialSetup()
    }
    
    func initialSetup()
    {
        self.usernameField?.text = "newuser"
        self.passwordField?.text = "1234567890"
        
        keepMeLoggedInButton.setImage(UIImage.init(named: "LoginChecked"), for: .normal)
        self.usernameField.delegate = self
        self.passwordField.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
    }
  
    
    @IBAction func tapOnSignIn(_ sender: Any) {
    
        self.view.endEditing(true)
        let userEmail = removeWhiteSpace(text: usernameField.text ?? "")
        let password = removeWhiteSpace(text: passwordField.text ?? "")
        
        let isValidated = self.validate(emailId: userEmail, password: password)
        if isValidated.0 == true {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let initial = storyboard.instantiateViewController(withIdentifier: "MonthViewController") as! MonthViewController
            self.navigationController?.pushViewController(initial, animated: true)
        }else {
            self.showAlertbanner(message: isValidated.1, title:CONTENT_CALENDAR_TITLE, controller: self)
        }
    }

    @IBAction func keepMeLoggedInButtonClicked(_ sender: Any) {
        
        if(keepMeLoggedInButton.image(for: .normal) == UIImage.init(named: "LoginUnChecked")) {
            keepMeLoggedInButton.setImage(UIImage.init(named: "LoginChecked"), for: .normal)
        }
        else{
            keepMeLoggedInButton.setImage(UIImage.init(named: "LoginUnChecked"), for: .normal)
        }
    }

    
    func validate(emailId: String, password: String) -> (Bool, String) {
        var isValidationSuccess = true
        var message:String = ""
        
        if emailId.count == 0{
            message = CONTENT_EMPTY_USERNAME
            isValidationSuccess = false
        }  else if password.count == 0{
            message = CONTENT_EMPTY_PASSWPRD
            isValidationSuccess = false
        }
        return (isValidationSuccess, message)
    }
 
    // for password show/hide
    @IBAction func passwordHideShow(sender: UIButton) {
        
        self.isPasswordHide = !self.isPasswordHide
        var image = UIImage(named: "icon_eye_open")
        if self.isPasswordHide {
            image = UIImage(named: "icon_eye_hide")
        }
        
        self.btnPwd.setImage(image, for: .normal)
        self.passwordField.isSecureTextEntry = self.isPasswordHide
    }
    
}


extension SignInViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        if (textField == passwordField){ //Password
            textField.isSecureTextEntry = isPasswordHide
            textField.returnKeyType = .done
        } else {
            textField.keyboardType = .emailAddress
        }
        
        return true
    }
}

