//
//  STSemester.swift
//  SNUTT
//
//  Created by Rajin on 2016. 2. 21..
//  Copyright © 2016년 WaffleStudio. All rights reserved.
//

import Foundation

enum STSemester : Int, Codable {
    case first = 1, summer, second, winter
    
    static let allValues = [first, summer, second, winter]
    
    func shortString() -> String {
        switch self {
        case .first: return "1"
        case .second: return "2"
        case .summer: return "S"
        case .winter: return "W"
        }
    }
    func longString() -> String {
        switch self {
        case .first: return NSLocalizedString("first_semester", comment: "")
        case .second: return NSLocalizedString("second_semester", comment: "")
        case .summer: return NSLocalizedString("summer_semester", comment: "")
        case .winter: return NSLocalizedString("winter_semester", comment: "")
        }
    }
}

extension STSemester : Comparable {}

func <<T: RawRepresentable>(a: T, b: T) -> Bool where T.RawValue: Comparable {
    return a.rawValue < b.rawValue
}
