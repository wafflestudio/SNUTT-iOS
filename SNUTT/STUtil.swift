//
//  STUtil.swift
//  SNUTT
//
//  Created by Rajin on 2016. 2. 11..
//  Copyright © 2016년 WaffleStudio. All rights reserved.
//

import Foundation
import UIKit

class STUtil {
    static func getRangeFromNSRange(_ string : String, range : NSRange) -> Range<String.Index>{
        let startIndex = string.characters.index(string.startIndex, offsetBy: range.location)
        let endIndex = string.characters.index(startIndex, offsetBy: range.length)
        return (startIndex ..< endIndex)
    }
    
    static func validateEmail(_ candidate: String) -> Bool {
        // from http://emailregex.com
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: candidate)
    }
    
    static func validatePassword(_ password: String) -> Bool {
        if let _ = password.range(of: "^(?=.*\\d)(?=.*[a-z])\\S{6,20}$", options: [.regularExpression, .caseInsensitive]) {
            return true
        }
        return false
    }
    
    static func validateId(_ id: String) -> Bool {
        if let _ = id.range(of: "^[a-z0-9]{4,32}$", options: [.regularExpression, .caseInsensitive]) {
            return true
        }
        return false
    }

    static func isEmptyOrNil(str : String?) -> Bool {
        return str == nil || str == ""
    }
}

extension String {
    func localizedString() -> String {
        return NSLocalizedString(self, comment: "")
    }
    var breakOnlyAtNewLineAndSpace : String {
        let sc : Character = "\u{FEFF}"
        var tmp : [Character] = []
        var flag = false
        for (index, ch) in self.characters.enumerated() {
            if ch == "\n" || ch == " " {
                flag = true
                tmp.append(ch)
            } else {
                if flag || index == 0 {
                    flag = false
                } else {
                    tmp.append(sc)
                }
                tmp.append(ch)
            }
        }
        return String(tmp)
    }
    func trunc(length: Int, trailing: String? = "...") -> String {
        if self.characters.count > length {
            return self.substring(to: self.index(self.startIndex, offsetBy: length)) + (trailing ?? "")
        } else {
            return self
        }
    }

    func isEnglish() -> Bool {
        let characterSet = CharacterSet.alphanumerics.inverted
        return (self.rangeOfCharacter(from: characterSet) != nil)
    }
}

extension UIView {
    
    func roundCorners(_ corners:UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
    
    func roundCorner(_ radius: CGFloat) {
        self.layer.cornerRadius = radius
        self.layer.masksToBounds = true
    }
    
    func setBottomBorder(_ color: UIColor, width: Double)
    {
        let border = CALayer()
        let width = CGFloat(width)
        border.borderColor = color.cgColor
        border.frame = CGRect(x: 0, y: self.frame.size.height - width,   width:  self.frame.size.width, height: self.frame.size.height)
        
        border.borderWidth = width
        self.layer.addSublayer(border)
        self.layer.masksToBounds = true
    }
    
    func mask(_ rect : CGRect) {
        let maskLayer = CAShapeLayer()
        let path = CGPath(rect: rect, transform: nil)
        maskLayer.path = path
        self.layer.mask = maskLayer
    }
}

extension RawRepresentable {
    init?(raw: Self.RawValue?) {
        if let rawValue = raw {
            self.init(rawValue: rawValue)
        } else {
            return nil
        }
    }
}

func getDocumentsDirectory() -> URL {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return paths[0]
}

func isLargerThanSE() -> Bool {
    return UIScreen.main.bounds.height > 700
}

extension Date {
    func yearsFrom(_ date: Date) -> Int {
        return (Calendar.current as NSCalendar).components(.year, from: date, to: self, options: []).year!
    }
    func monthsFrom(_ date: Date) -> Int {
        return (Calendar.current as NSCalendar).components(.month, from: date, to: self, options: []).month!
    }
    func weeksFrom(_ date: Date) -> Int {
        return (Calendar.current as NSCalendar).components(.weekOfYear, from: date, to: self, options: []).weekOfYear!
    }
    func daysFrom(_ date: Date) -> Int {
        return (Calendar.current as NSCalendar).components(.day, from: date, to: self, options: []).day!
    }
    func hoursFrom(_ date: Date) -> Int {
        return (Calendar.current as NSCalendar).components(.hour, from: date, to: self, options: []).hour!
    }
    func minutesFrom(_ date: Date) -> Int{
        return (Calendar.current as NSCalendar).components(.minute, from: date, to: self, options: []).minute!
    }
    func secondsFrom(_ date: Date) -> Int{
        return (Calendar.current as NSCalendar).components(.second, from: date, to: self, options: []).second!
    }
    func offsetFrom(_ date: Date) -> String {
        if yearsFrom(date)   > 0 { return "\(yearsFrom(date))년전"   }
        if monthsFrom(date)  > 0 { return "\(monthsFrom(date))달전"  }
        if daysFrom(date)    > 0 { return "\(daysFrom(date))일전"    }
        if hoursFrom(date)   > 0 { return "\(hoursFrom(date))시간전"   }
        if minutesFrom(date) > 0 { return "\(minutesFrom(date))분전" }
        if secondsFrom(date) > 0 { return "\(secondsFrom(date))초전" }
        return ""
    }
}

public extension UIImage {
    public convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
}

extension UITextField {
    // This is for korean in textfield with no textborder bug
    // link : https://stackoverflow.com/questions/39556087/uitextfield-chinese-character-moves-down-when-editing-in-ios-10

    @IBInspectable var hideBorder: Bool {
        get {
            return borderStyle == UITextField.BorderStyle.none
        }
        set {
            if newValue {
                borderStyle = UITextField.BorderStyle.line
                borderStyle = UITextField.BorderStyle.none
            }
        }
    }
}

extension Collection {
    func get(_ index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

