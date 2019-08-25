//
//  STDefaults.swift
//  SNUTT
//
//  Created by Rajin on 2016. 4. 24..
//  Copyright © 2016년 WaffleStudio. All rights reserved.
//

import Foundation
import UIKit
import SwiftyUserDefaults

extension DefaultsKeys {
    static let token = DefaultsKey<String?>("token")
    static let userId = DefaultsKey<String?>("userId")
    static let appVersion = DefaultsKey<String>("appVersion")
    static let autoFit = DefaultsKey<Bool>("autoFit", true)
    static let dayRange = DefaultsKey<[Int]>("dayRange", [0,4])
    static let timeRange = DefaultsKey<[Double]>("timeRange", [0.0, 14.0])
    static let registeredFCMToken = DefaultsKey<String?>("registeredFCMToken")
    static let shouldShowBadge = DefaultsKey<Bool>("shouldShowBadge", false)
    static let currentTimetableOld = DefaultsKey<NSDictionary?>("currentTimetable")
    static let currentTimetable = DefaultsKey<STTimetable?>("currentTimetable2")
    static let shouldDeleteFCMInfos = DefaultsKey<STFCMInfoList?>("shouldDeleteFCMInfos")
    static let colorList = DefaultsKey<STColorList?>("colorList")
    static let lastVersion = DefaultsKey<String?>("lastVersion")
    static let courseBookList = DefaultsKey<[STCourseBook]>("courseBookList", [])
}

extension UserDefaults {
    subscript<T: Codable>(key: DefaultsKey<T?>) -> T? {
        get {
            guard let data = object(forKey: key._key) as? Data else { return nil }
            return try? PropertyListDecoder().decode(T.self, from: data)
        }
        set {
            if let newValue = newValue {
                set(try? PropertyListEncoder().encode(newValue), forKey: key._key)
            } else {
                set(nil, forKey: key._key)
            }
        }
    }
    subscript<T: Codable>(key: DefaultsKey<T>) -> T {
        get {
            guard let data = object(forKey: key._key) as? Data else { return key._default! }
            if let result = try? PropertyListDecoder().decode(T.self, from: data) {
                return result
            } else {
                return key._default!
            }
        }
        set {
            set(try? PropertyListEncoder().encode(newValue), forKey: key._key)
        }
    }
    subscript(key: DefaultsKey<NSDictionary?>) -> NSDictionary? {
        get { return unarchive(key) }
        set { archive(key, newValue) }
    }
}

public let STDefaults = UserDefaults(suiteName: Bundle.main.object(forInfoDictionaryKey: "AppGroupID") as! String)!
