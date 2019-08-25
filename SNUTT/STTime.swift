//
//  STTime.swift
//  SNUTT
//
//  Created by Rajin on 2015. 9. 6..
//  Copyright (c) 2015년 WaffleStudio. All rights reserved.
//

import Foundation

struct STTime : Hashable {
    var day : STDay
    var startPeriod : Double
    var duration : Double
    var endPeriod : Double {
        return startPeriod + duration
    }
    
    init(day: Int, startPeriod: Double, duration: Double) {
        self.day = STDay(rawValue: day)!
        self.startPeriod = startPeriod
        self.duration = duration
    }
    
    func longString() -> String {
        return day.longString() + " " + startPeriod.periodString() + "~" + endPeriod.periodString()
    }
    
    func shortString() -> String {
        return day.shortString() + " " + startPeriod.periodString() + "~" + endPeriod.periodString()
    }
    
    func startString() -> String {
        return day.shortString() + String.init(format: "%g", startPeriod)
    }
    
    func isOverlappingWith(_ tmp : STTime) -> Bool {
        if day != tmp.day {
            return false
        }
        if tmp.startPeriod < startPeriod {
            if (tmp.startPeriod + tmp.duration > startPeriod) {
                return true
            }
            return false
        } else {
            if (startPeriod + duration > tmp.startPeriod) {
                return true
            }
            return false
        }
    }
}

extension STTime : Equatable {}

func ==(lhs: STTime, rhs: STTime) -> Bool {
    return lhs.day == rhs.day && lhs.startPeriod == rhs.startPeriod && lhs.duration == rhs.duration
}
