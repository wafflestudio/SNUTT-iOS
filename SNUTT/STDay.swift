//
//  STDay.swift
//  SNUTT
//
//  Created by Rajin on 2016. 2. 21..
//  Copyright © 2016년 WaffleStudio. All rights reserved.
//

import Foundation

enum STDay : Int, Hashable {
    case mon=0, tue, wed, thu, fri, sat, sun
    
    static let allValues = [mon, tue, wed, thu, fri, sat, sun]
    
    func shortString() -> String {
        switch self {
        case .mon: return NSLocalizedString("monday_short", comment: "")
        case .tue: return NSLocalizedString("tuesday_short", comment: "")
        case .wed: return NSLocalizedString("wednesday_short", comment: "")
        case .thu: return NSLocalizedString("thursday_short", comment: "")
        case .fri: return NSLocalizedString("friday_short", comment: "")
        case .sat: return NSLocalizedString("saturday_short", comment: "")
        case .sun: return NSLocalizedString("sunday_short", comment: "")
        }
    }
    
    func longString() -> String {
        switch self {
        case .mon: return NSLocalizedString("monday", comment: "")
        case .tue: return NSLocalizedString("tuesday", comment: "")
        case .wed: return NSLocalizedString("wednesday", comment: "")
        case .thu: return NSLocalizedString("thursday", comment: "")
        case .fri: return NSLocalizedString("friday", comment: "")
        case .sat: return NSLocalizedString("saturday", comment: "")
        case .sun: return NSLocalizedString("sunday", comment: "")
        }
    }
}

extension STDay: Comparable {}

class STDayFormatter : NumberFormatter {
    override func string(from number: NSNumber) -> String? {
        let val = number.intValue
        if 0 <= val && val <= 6 {
            return STDay(rawValue: val)!.shortString()
        } else {
            return ""
        }
    }
}
