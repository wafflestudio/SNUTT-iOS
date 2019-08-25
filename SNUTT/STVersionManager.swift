//
//  STVersionManager.swift
//  SNUTT
//
//  Created by Rajin on 2019. 3. 30..
//  Copyright © 2019년 WaffleStudio. All rights reserved.
//

import Foundation

class STVersionManager {
    // TODO: change to version check, not string comparison.

    func checkUpgrade() {
        let currentVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
        let lastVersion = STDefaults[.lastVersion]
        if (lastVersion == currentVersion) {
            return
        }
        onUpgrade(oldVersion: lastVersion, newVersion: currentVersion)
        STDefaults[.lastVersion] = currentVersion
        STDefaults.synchronize()
    }

    func onUpgrade(oldVersion: String?, newVersion: String) {
        let oldVersion = oldVersion ?? "0.0.0"
        if oldVersion < "1.1.0" {
            STDefaults[.colorList] = nil
            STDefaults[.shouldDeleteFCMInfos] = nil
            let dict = STDefaults[.currentTimetableOld]
            let timetable = (try? dict?.swiftDictionary.toObject(STTimetable.self)) ?? nil
            STDefaults[.currentTimetable] = timetable
        }
    }
}
