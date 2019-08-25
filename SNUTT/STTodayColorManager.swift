//
//  STTodayColorManager.swift
//  SNUTT
//
//  Created by Rajin on 2017. 3. 18..
//  Copyright © 2017년 WaffleStudio. All rights reserved.
//

class STTodayColorManager {

    // MARK: Singleton

    fileprivate static var sharedManager : STTodayColorManager? = nil
    static var sharedInstance : STTodayColorManager{
        get {
            if sharedManager == nil {
                sharedManager = STTodayColorManager()
            }
            return sharedManager!
        }
    }

    fileprivate init() {
        self.loadData()
    }

    var colorList: STColorList = STColorList(colorList: [], nameList: [])

    func loadData() {
        colorList = STDefaults[.colorList] ?? STColorList(colorList: [], nameList: [])
    }

    func saveData() {
        STDefaults[.colorList] = colorList
    }

}

