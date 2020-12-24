//
//  CalendarDataTableViewCell.swift
//  CalendarEntries
//
//  Created by user on 12/23/20.
//  Copyright © 2020 Zirius. All rights reserved.
//

import UIKit

class CalendarDataTableViewCell: UITableViewCell {
    

    @IBOutlet weak var lblPositionName: UILabel!
    @IBOutlet weak var lblDateTime: UILabel!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var leftBtn: UIButton!
    @IBOutlet weak var rightBtn: UIButton!
    
    
    // Swipe
    @IBOutlet weak var rightSwipeConstantWidth: NSLayoutConstraint!
    @IBOutlet weak var leftSwipeConstantIWidth: NSLayoutConstraint!
    @IBOutlet weak var mainViewLeftTraling: NSLayoutConstraint!
    @IBOutlet weak var mainViewRightLeading: NSLayoutConstraint!
    var leftSwipe: UISwipeGestureRecognizer?
    var rightSwipe: UISwipeGestureRecognizer?
    var rightSwipeDisable: Bool? = true
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.initialSetup()
    }

    func initialSetup() {
        self.mainView.isUserInteractionEnabled = true
        self.leftBtn.backgroundColor = UIColor.getAppLightBlackColor()
        self.rightBtn.backgroundColor = UIColor.getAppRedColor()
        self.leftBtn.titleLabel?.font = UIFont(name: "Montserrat-SemiBold", size: 14)
        self.leftBtn.setTitle("Edit", for: .normal)
        self.rightBtn.titleLabel?.font = UIFont(name: "Montserrat-SemiBold", size: 14)
        self.rightBtn.setTitle("Delete", for: .normal)
        self.leftBtn.setTitleColor(UIColor.white, for: .normal)
        self.rightBtn.setTitleColor(UIColor.white, for: .normal)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }    
    
    
    func addSwipeGestures(){
        self.leftSwipe = UISwipeGestureRecognizer(target: self, action:#selector(self.swipeRight))
        self.leftSwipe?.direction = .left;
        self.mainView.addGestureRecognizer(self.leftSwipe!)
        self.rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(self.swipeRight))
        self.rightSwipe?.direction = .right;
        self.mainView.addGestureRecognizer(self.rightSwipe!)
        self.rightSwipeDisable = true
    }
    
    func removeSwipeGestures(){
        if let recognizers = mainView.gestureRecognizers {
            for recognizer in recognizers {
                mainView.removeGestureRecognizer(recognizer)
            }
        }
    }
    
    @objc func swipeRight(sender:AnyObject)  {
        
        UIView.animate(withDuration: 0.15, delay: 0.0, options: .curveEaseIn,
                       animations: {
                        self.rightSwipeConstantWidth.constant = 0
                        self.leftSwipeConstantIWidth.constant = 0
                        self.layoutIfNeeded()},
                       completion: nil)
        
        let swipeGesture:UISwipeGestureRecognizer = sender as! UISwipeGestureRecognizer
        if(swipeGesture.direction == .left)
        {
            self.layoutIfNeeded()
            if self.mainViewRightLeading.constant == -50 {
                UIView.animate(withDuration: 0.5, delay: 0.1, options: .curveEaseIn,
                               animations: {
                                self.mainViewRightLeading.constant = 0
                                self.mainViewLeftTraling.constant = 0
                                self.layoutIfNeeded()},
                               completion: nil)
                
            }else {
                UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseInOut,
                               animations: {
                                self.mainViewLeftTraling.constant =  -50
                                self.rightSwipeConstantWidth.constant = 70
                                self.layoutIfNeeded()},
                               completion: nil)
            }
        }
        if(swipeGesture.direction == .right)
        {
            //print(self.mainViewRightLeading)
            self.layoutIfNeeded()
            if self.mainViewLeftTraling.constant == -50 {
                UIView.animate(withDuration: 0.5, delay: 0.1, options: .curveEaseIn,
                               animations: {
                                self.mainViewLeftTraling.constant = 0
                                self.mainViewRightLeading.constant = 0
                                self.layoutIfNeeded()},
                               completion: nil)
                
            }else {
                
                if self.rightSwipeDisable == false {
                    return
                }
                UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseInOut,
                               animations: {
                                self.mainViewRightLeading.constant =  -50
                                self.leftSwipeConstantIWidth.constant = 70
                                self.layoutIfNeeded()},
                               completion: nil)
            }
        }
        
    }
    
}
