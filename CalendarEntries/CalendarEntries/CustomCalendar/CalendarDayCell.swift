/*
 * CalendarDayCell.swift
 * Created by Michael Michailidis on 02/04/2015.
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

open class CalendarDayCell: UICollectionViewCell {
    
    override open var description: String {
        let dayString = self.textLabel.text ?? " "
        return "<DayCell (text:\"\(dayString)\")>"
    }
    
    var eventsCount = 0 {
        didSet {
            self.stackView.isHidden = (eventsCount == 0)
            self.setNeedsLayout()
        }
    }

    var isToday : Bool = false {
        didSet {
            switch isToday {
            case true:
                self.textLabel.textColor =   UIColor.black
                self.bgView.layer.borderColor = UIColor.init(hexString: "#1AF2E6").cgColor
                self.bgView.layer.borderWidth = 1.0
                self.textLabel.font = UIFont(name: "Montserrat-Medium", size: 18)
                self.bgView.backgroundColor = UIColor.appThemeDisableColor()
            case false:
                self.bgView.backgroundColor = CalendarView.Style.cellColorDefault
                //self.textLabel.textColor = CalendarView.Style.cellTextColorDefault
                self.textLabel.textColor = UIColor.init(hexString: "#1D1D46")
                self.textLabel.font = UIFont(name: "Montserrat-Medium", size: 18)
            }
        }
    }
    
    override open var isSelected : Bool {
        didSet {
            switch isSelected {
            case true:
                //NewCalendar
                self.bgView.layer.borderColor = UIColor.appThemeColor().cgColor
                self.bgView.layer.borderWidth = 0.0
                self.bgView.backgroundColor = UIColor.appThemeColor()
                self.bgView.layer.borderWidth = 2.0
            case false:
                self.bgView.layer.borderColor = UIColor.clear.cgColor
                self.bgView.layer.borderWidth = 0.0
            }
        }
    }

    let textLabel   = UILabel()
    let dotsViewOne    = UILabel()
    let bgView      = UIView()
    let stackView   = UIStackView()
    
    override init(frame: CGRect) {
        self.textLabel.textAlignment = NSTextAlignment.center
        self.dotsViewOne.backgroundColor = UIColor.clear
        self.stackView.backgroundColor = UIColor.clear
        super.init(frame: frame)
        self.stackView.distribution = .fillEqually
        self.addSubview(self.bgView)
        self.addSubview(self.textLabel)
        self.addSubview(self.stackView)
        self.stackView.addArrangedSubview(self.dotsViewOne)

    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override open func layoutSubviews() {
        
        super.layoutSubviews()
        
        var elementsFrame = self.bounds.insetBy(dx: 3.0, dy: 3.0)
        
        if CalendarView.Style.cellShape.isRound { // square of
            let smallestSide = min(elementsFrame.width + 0 , elementsFrame.height + 0)
            elementsFrame = elementsFrame.insetBy(
                dx: (elementsFrame.width - smallestSide) / 2.0,
                dy: (elementsFrame.height - smallestSide) / 2.0
            )
        }
        
        self.bgView.frame           = elementsFrame
        self.textLabel.frame        = elementsFrame
        
        self.dotsViewOne.text =  ""
        self.dotsViewOne.textAlignment = .center
        self.dotsViewOne.font = UIFont(name: "Montserrat-Medium", size: 10)

        let size                            = self.bounds.height * 0.08
        self.stackView.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: 10)
        self.stackView.center = CGPoint(x: self.textLabel.center.x, y: self.bounds.height - (2.5 * size))
        
        switch CalendarView.Style.cellShape {
        case .square:
            self.bgView.layer.cornerRadius = 0.0
        case .round:
            self.bgView.layer.cornerRadius = elementsFrame.width * 0.5
        case .bevel(let radius):
            self.bgView.layer.cornerRadius = radius
        }
    }
    
}
