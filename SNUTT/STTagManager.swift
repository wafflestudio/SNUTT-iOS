//
//  STTagManager.swift
//  SNUTT
//
//  Created by Rajin on 2016. 3. 4..
//  Copyright © 2016년 WaffleStudio. All rights reserved.
//

import Foundation
import Alamofire

class STTagManager {
    
    // MARK: Singleton
    
    fileprivate static var sharedManager : STTagManager? = nil
    static var sharedInstance : STTagManager{
        get {
            if sharedManager == nil {
                sharedManager = STTagManager()
            }
            return sharedManager!
        }
    }
    
    fileprivate init() {
        self.loadData()
        STEventCenter.sharedInstance.addObserver(self, selector: #selector(STTagManager.loadData), event: STEvent.CurrentTimetableSwitched, object: nil)
    }
    
    var tagList : STTagList!
    
    @objc dynamic func loadData() {
        guard let quarter = STTimetableManager.sharedInstance.currentTimetable?.quarter else {
            return
        }
        let tagList = NSKeyedUnarchiver.unarchiveObject(withFile: getDocumentsDirectory().appendingPathComponent("tagList\(quarter.shortString()).archive")) as? STTagList
        if tagList != nil {
            self.tagList = tagList
        } else {
            self.tagList = STTagList(quarter: quarter, tagList: [], updatedTime: 0)
        }
        self.updateTagList()
    }
    
    func saveData(_ quarter: STQuarter) {
        NSKeyedArchiver.archiveRootObject(self.tagList, toFile: getDocumentsDirectory().appendingPathComponent("tagList\(quarter.shortString()).archive"))
    }
    
    
    
    
    func getTagListWithQuarter(_ quarter: STQuarter, updatedTime : Int64) {
        STNetworking.getTagListForQuarter(quarter, done: { tagList in
            if self.tagList.quarter == quarter {
                self.tagList = tagList
                self.saveData(quarter)
            }
        }, failure: { 
            self.tagList = STTagList(quarter: quarter, tagList: [], updatedTime: 0)
        })
    }


    
    func updateTagList() {
        STNetworking.getTagUpdateTimeForQuarter(tagList.quarter, done: { updatedTime in
            if self.tagList.updatedTime != updatedTime {
                    self.getTagListWithQuarter(self.tagList.quarter, updatedTime: updatedTime)
            }
            }, failure: nil
        )
    }

}
