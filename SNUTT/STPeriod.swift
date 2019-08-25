//
//  STPeriod.swift
//  SNUTT
//
//  Created by Rajin on 2016. 2. 21..
//  Copyright © 2016년 WaffleStudio. All rights reserved.
//

import Foundation

extension Double {
    func periodString() -> String {
        if Int(self * 2.0) % 2 == 0 {
            return "\(Int(self)+8):00"
        } else {
            return "\(Int(self)+8):30"
        }
    }

    func shortPeriodString() -> String {
        return "\(Int(self)+8)"
    }
}

extension Int {
    func shortPeriodSring() -> String {
        return "\(self+8)"
    }
}

class STPeriod {
    static let periodNum : Int = 14
    static var allValues : [Double] {
        var arr : [Double] = []
        for i in 0..<STPeriod.periodNum {
            arr.append(Double(i))
            arr.append(Double(i)+0.5)
        }
        return arr
    }
}

class STPeriodFormatter : NumberFormatter {
    override func string(from number: NSNumber) -> String? {
        let val = number.doubleValue
        if Int(val * 2.0) % 2 == 0 {
            return "\(Int(val))"
        } else {
            return "\(Int(val)).5"
        }
    }
}
