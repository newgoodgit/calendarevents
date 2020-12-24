//
//  SGINAddAvailabilityViewController.swift
//  CalendarEntries
//
//  Created by user on 12/23/20.
//  Copyright © 2020 Zirius. All rights reserved.
//


import UIKit
import CoreData
import CoreFoundation

class SGINAddAvailabilityViewController: UIViewController {
    
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var btnAddAvailability: UIButton!
    @IBOutlet weak var txtStartdate: UITextField!
    @IBOutlet weak var txtView: UITextView!

    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var pickerView: UIDatePicker?
    var isEdit: Bool? = false
    var isEventID: String? = ""
    var isEventDate: String? = ""
    var isEventDescription: String? = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialLoad()
        self.setViewLayer()
    }
    
    func initialLoad() {
        
        self.btnCancel.addTarget(self, action: #selector(self.btnCancelTapped), for: .touchUpInside)
        self.btnAddAvailability.addTarget(self, action: #selector(self.btnAddAvailabilityTapped), for: .touchUpInside)
        self.txtStartdate.delegate = self
        self.txtStartdate.tag = 8000
    }
    
    func setViewLayer() {
        self.txtView.text = ""
        self.txtView.contentInset = UIEdgeInsets(top: 2, left: 10, bottom: 2, right: 10)
        self.txtView.font = UIFont.setAppFontRegular(14)
        self.txtView.clipsToBounds = true
        self.txtView.layer.cornerRadius = 6.0
        self.txtView.layer.borderColor = UIColor.init(hexString: "#DEDEDE").cgColor
        self.txtView.layer.borderWidth = 1.0
        self.txtView.backgroundColor = UIColor.clear
        self.txtView.layer.sublayerTransform = CATransform3DMakeTranslation(-5, 0, 0)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if self.isEdit == true {
            self.txtStartdate?.text = self.isEventDate
            self.txtView?.text = self.isEventDescription
        }
        
    }
}
extension SGINAddAvailabilityViewController {
    
    @objc func btnCancelTapped(sender:UIButton)  {      
        self.navigationController?.popViewController(animated: true)
    }
    @objc func btnAddAvailabilityTapped(sender:UIButton)  {
        if self.isValidationSuccess(){
            let context = appDelegate.persistentContainer.viewContext
            let entity = NSEntityDescription.entity(forEntityName: TBL_CALENDAR_EVENT, in: context)
            if self.isEdit == true {
                let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: TBL_CALENDAR_EVENT)
                let predicate = NSPredicate(format: "eventsid == %@", self.isEventID!)
                fetch.predicate = predicate
                do {
                    let result = try context.fetch(fetch)
                    for data in result as! [NSManagedObject] {
                        data.setValue(self.isEventID, forKey: "eventsid")
                        data.setValue(self.txtStartdate?.text, forKey: "eventsdate")
                        data.setValue(self.txtView?.text, forKey: "eventsdecs")
                    }
                    try context.save()
                    self.moveToCalendar()
                } catch {
                    print("Failed")
                }
            }else {
                let newCalendar = NSManagedObject(entity: entity!, insertInto: context)
                newCalendar.setValue(String(format: "%@", self.randomString(6)), forKey: "eventsid")
                newCalendar.setValue(self.txtStartdate?.text, forKey: "eventsdate")
                newCalendar.setValue(self.txtView?.text, forKey: "eventsdecs")
                do {
                   try context.save()
                    self.moveToCalendar()
                  } catch {
                   print("Failed saving")
                }
            }
            
        }
    }
    
    func moveToCalendar()  {
        self.showAlertbanner(message: "Value updated", title:CONTENT_CALENDAR_UPADTED_MSG, controller: self)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0){
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func getDateFormat(dateValue: Date) -> String{
           let formatter: DateFormatter = DateFormatter()
           //formatter.timeZone = TimeZone(abbreviation: "UTC")
           formatter.dateFormat = "dd-MMM-yyyy"
           let dateValue = formatter.string(from: dateValue)
           return dateValue
    }
    
    
    func randomString(_ length: Int) -> String {
           let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
           let len = UInt32(letters.length)
           var randomString = ""
           for _ in 0 ..< length {
               let rand = arc4random_uniform(len)
               var nextChar = letters.character(at: Int(rand))
               randomString += NSString(characters: &nextChar, length: 1) as String
           }
           return randomString
    }
    
}
extension SGINAddAvailabilityViewController: UITextFieldDelegate{
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == self.txtStartdate {
            self.pickerView = UIDatePicker()
            self.pickerView?.datePickerMode = .date
            if textField == self.txtStartdate{
                self.pickerView?.tag = 9000
                textField.inputView = pickerView
            }
            if textField.text == ""{
//                let dateFormatter: DateFormatter = DateFormatter()
//                dateFormatter.dateFormat = "MM/dd/yyyy"
//                let selectedDate: String = dateFormatter.string(from: Date())
                textField.text = self.getDateFormat(dateValue: self.pickerView?.date ?? Date())
            }
            pickerView?.addTarget(self, action: #selector(self.datePickerChanged(sender:)), for: .valueChanged)
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
    }
    
    @objc func datePickerChanged(sender:UIDatePicker) {
        
        if sender.tag == 9000 || sender.tag == 9003 {
//            let dateFormatter: DateFormatter = DateFormatter()
//            dateFormatter.dateFormat = "MM/dd/yyyy"
//            let selectedDate: String = dateFormatter.string(from: sender.date)
            if sender.tag == 9000{
                self.txtStartdate?.text = self.getDateFormat(dateValue: self.pickerView?.date ?? Date())
            }
            self.txtStartdate.resignFirstResponder()
        }
        
    }
}
extension SGINAddAvailabilityViewController {
    
    func isValidationSuccess() -> Bool {
        
        self.view.endEditing(true)
        var isValidationSuccess = true
        var message = ""
        
        if self.removeWhiteSpace(text: self.txtStartdate?.text ?? "").count == 0 {
            message = CONTENT_ADD_EVENT_DATE
            isValidationSuccess = false
        }else if self.removeWhiteSpace(text: self.txtView?.text ?? "").count == 0 {
            message = CONTENT_ADD_EVENT_DESCRIPTION
            isValidationSuccess = false
        }
            
        if !isValidationSuccess {
            self.showAlertbanner(message: message, title:CONTENT_CALENDAR_TITLE, controller: self)
        }
        return isValidationSuccess
    }
   
}



