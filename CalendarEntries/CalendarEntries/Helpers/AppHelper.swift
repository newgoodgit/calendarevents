//
//  AppHelper.swift
//
//


import UIKit

public extension UIColor {
    
    class func refreshCtrlColor() -> UIColor {
        return UIColor.appThemeColor()
    }
    
    class func appThemeColor()->UIColor {
        return UIColor.init(netHex: 0x72EEE5)
    }
    
    class func bidButtonColor()->UIColor {
        return UIColor.init(netHex: 0x1AF2E6)
    }
    
    class func appThemeDisableColor()->UIColor {
        return UIColor.init(netHex: 0x97F4EE)
    }
    
    class func getAppGreenishBlueColor()->UIColor{
        return UIColor.init(netHex: 0x1AF2E6)
    }
    
    class func getAppLightBlackColor()->UIColor{
        return UIColor.init(netHex: 0x1D1D46)
    }
    
    class func getAppRedColor()->UIColor{
        return UIColor.init(netHex: 0xE4103F)
    }
    
    class func getAppGreyColor()-> UIColor{
        return UIColor.init(netHex: 0xA5A5B5)
    }
    
    class func getAppLightBackgroundColor()->UIColor{
        return UIColor.init(netHex: 0xF5FAFA)
    }
}
// MARK: - Extensions
extension UIColor {
    
    convenience init(red: Int, green: Int, blue: Int) {
        
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(netHex:Int) {
        
        self.init(red:(netHex >> 16) & 0xff, green:(netHex >> 8) & 0xff, blue:netHex & 0xff)
    }
    
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt32()
        Scanner(string: hex).scanHexInt32(&int)
        let a, r, g, b: UInt32
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}

//MARK:- Custom Method for APP Used Font
extension UIFont {
    
    class func setAppFontRegular(_ size:CGFloat)->(UIFont) {
        return UIFont(name: "AvenirNext-Regular", size: 14) ?? UIFont.systemFont(ofSize: 14)
    }
    
    class func setAppFontMedium(_ size:CGFloat)->(UIFont) {
        return UIFont(name: "AvenirNext-Medium", size: size)!
    }
    
    class func setAppFontSemiBold(_ size:CGFloat)->(UIFont) {
        return UIFont(name: "AvenirNext-DemiBold", size: size)!
    }
    
    class func setAppFontBold(_ size:CGFloat)->(UIFont) {
        return UIFont(name: "AvenirNext-Bold", size: size)!
    }
    
    class func setAppFontHeader(_ size:CGFloat)->(UIFont) {
        return UIFont(name: "AvenirNext-Regular", size: size)!
    }
}

public class BtnEmerald: UIButton {
    
    override init(frame: CGRect){
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonSetup()
    }
    
    private func commonSetup() {
        self.titleLabel?.font = UIFont.setAppFontSemiBold(12)
        self.backgroundColor = UIColor.getAppGreenishBlueColor()
        self.titleLabel?.textColor = UIColor.getAppLightBlackColor()
        self.layer.cornerRadius = 10.0
        self.layer.borderColor = UIColor.getAppGreenishBlueColor().cgColor
        self.layer.borderWidth = 1.0
    }
}

public extension UIViewController {
    
    func removeWhiteSpace(text:String) -> String
    {
         return text.trimmingCharacters(in: CharacterSet.whitespaces)
        
    }
    
    func showAlertbanner(message: String, title:String, controller: UIViewController) {
        // the alert view
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        controller.present(alert, animated: true, completion: nil)
        // change to desired number of seconds (in this case 5 seconds)
        let when = DispatchTime.now() + 1.5
        DispatchQueue.main.asyncAfter(deadline: when){
            // your code with delay
            alert.dismiss(animated: true, completion: nil)
        }
    }
    
    func getAPIDateFormat(dateValue : Date) -> String{
           let formatter: DateFormatter = DateFormatter()
           formatter.timeZone = TimeZone(abbreviation: "UTC")
           formatter.dateFormat = "dd-MMM-yyyy"
           let dateValue = formatter.string(from: dateValue)
           return dateValue
    }
}
extension String {
    
    func isAlphanumeric() -> Bool {
        return self.rangeOfCharacter(from: CharacterSet.alphanumerics.inverted) == nil && self != ""
    }
    
    func isAlphanumeric(ignoreDiacritics: Bool = false) -> Bool {
        if ignoreDiacritics {
            return self.range(of: "[^a-zA-Z0-9]", options: .regularExpression) == nil && self != ""
        }
        else {
            return self.isAlphanumeric()
        }
    }
    
    func widthOfString(usingFont font: UIFont) -> CGFloat {
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = self.size(withAttributes: fontAttributes)
        return size.width
    }
    
    func capitalizingFirstLetter() -> String {
        return prefix(1).uppercased() + dropFirst()
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}
let CONTENT_ADD_EVENT_DATE = "Please select date"
let CONTENT_ADD_EVENT_DESCRIPTION = "Please enter description"
let CONTENT_CALENDAR_UPADTED_MSG = "Calendar event upadated"
let CONTENT_CALENDAR_REFERSH = "Calendar event refersh"
let CONTENT_CALENDAR_TITLE = "CALENDAR EVENT"
let TBL_CALENDAR_EVENT = "Calendarevents"

let CONTENT_EMPTY_USERNAME = "Enter Email ID to continue"
let CONTENT_INVALID_EMAIL = "Invalid Email" //Enter valid email ID
let CONTENT_RESET_LINK_SENT = "Reset Link has been sent to your email"
let CONTENT_EMPTY_PASSWPRD = "Enter Password to continue"

let CONTENT_LOGOUT_MESSAGE = "Are sure you want to Logout?"

