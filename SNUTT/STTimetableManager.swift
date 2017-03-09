//
//  STTimetableManager.swift
//  SNUTT
//
//  Created by Rajin on 2016. 1. 6..
//  Copyright © 2016년 WaffleStudio. All rights reserved.
//

import Foundation
import SwiftyJSON

class STTimetableManager : NSObject {
    
    // MARK: Singleton
    
    private static var sharedManager : STTimetableManager? = nil
    static var sharedInstance : STTimetableManager{
        get {
            if sharedManager == nil {
                sharedManager = STTimetableManager()
                let _ = STTagManager.sharedInstance
            }
            return sharedManager!
        }
    }
    private override init() {
        super.init()
        self.loadData()
        if let timetableId = currentTimetable?.id {
            STNetworking.getTimetable(timetableId, done: { timetable in
                self.currentTimetable = timetable
            }, failure: { _ in
                self.currentTimetable = nil
            })
        }
        STEventCenter.sharedInstance.addObserver(self, selector: #selector(STTimetableManager.saveData), event: STEvent.CurrentTimetableChanged, object: nil)
    }
    
    deinit {
        STEventCenter.sharedInstance.removeObserver(self)
    }
    
    var currentTimetable : STTimetable? {
        didSet {
            STEventCenter.sharedInstance.postNotification(event: STEvent.CurrentTimetableSwitched, object: self)
            saveData()
        }
    }

    func loadData() {
        if let dict = STDefaults[.currentTimetable] {
            let timetable = STTimetable(json: JSON(dict))
            currentTimetable = timetable
        }
    }
    
    func saveData() {
        let dict = currentTimetable?.toDictionary()
        STDefaults[.currentTimetable] = dict as? NSDictionary
        STDefaults.synchronize()
    }
    
    func addCustomLecture(var lecture : STLecture, object : AnyObject? ) -> STAddLectureState {
        if currentTimetable == nil {
            return STAddLectureState.Success
        }
        let ret = currentTimetable!.addLecture(lecture)
        if case STAddLectureState.Success = ret {
            STNetworking.addCustomLecture(currentTimetable!, lecture: lecture, done: { newTimetable in
                self.currentTimetable?.lectureList = newTimetable.lectureList
                STEventCenter.sharedInstance.postNotification(event: .CurrentTimetableChanged, object: object)
                }, failure: {
                self.currentTimetable?.deleteLecture(lecture)
                STEventCenter.sharedInstance.postNotification(event: .CurrentTimetableChanged, object: object)
            })
            STEventCenter.sharedInstance.postNotification(event: STEvent.CurrentTimetableChanged, object: object)
        } else if case STAddLectureState.ErrorTime = ret {
            STAlertView.showAlert(title: "강의 추가 실패", message: "겹치는 시간대가 있습니다.")
        } else if case STAddLectureState.ErrorSameLecture = ret {
            STAlertView.showAlert(title: "강의 추가 실패", message: "같은 강좌가 이미 존재합니다.")
        }
        
        return ret
    }
    
    func addLecture(var lecture : STLecture, object : AnyObject? ) -> STAddLectureState {
        if currentTimetable == nil {
            return STAddLectureState.Success
        }
        let ret = currentTimetable!.addLecture(lecture)
        if case STAddLectureState.Success = ret {
            STNetworking.addLecture(currentTimetable!, lectureId: lecture.id!, done: { newTimetable in
                self.currentTimetable?.lectureList = newTimetable.lectureList
                STEventCenter.sharedInstance.postNotification(event: .CurrentTimetableChanged, object: object)
                }, failure: {
                    self.currentTimetable?.deleteLecture(lecture)
                    STEventCenter.sharedInstance.postNotification(event: .CurrentTimetableChanged, object: object)
            })
            STEventCenter.sharedInstance.postNotification(event: STEvent.CurrentTimetableChanged, object: object)
        } else if case STAddLectureState.ErrorTime = ret {
            STAlertView.showAlert(title: "강의 추가 실패", message: "겹치는 시간대가 있습니다.")
        } else if case STAddLectureState.ErrorSameLecture = ret {
            STAlertView.showAlert(title: "강의 추가 실패", message: "같은 강좌가 이미 존재합니다.")
        }
        
        return ret
    }
    
    func updateLecture(oldLecture : STLecture, newLecture : STLecture, failure: ()->()) {
        if currentTimetable == nil {
            return
        }
        let index = currentTimetable!.lectureList.indexOf({ lec in
            return lec.id == newLecture.id
        })!
        
        currentTimetable!.updateLectureAtIndex(index, lecture: newLecture)
        STEventCenter.sharedInstance.postNotification(event: .CurrentTimetableChanged, object: nil)
        
        STNetworking.updateLecture(currentTimetable!, oldLecture: oldLecture, newLecture: newLecture, done: { newTimetable in
            self.currentTimetable?.lectureList = newTimetable.lectureList
            STEventCenter.sharedInstance.postNotification(event: .CurrentTimetableChanged, object: nil)
            }, failure: {
                self.currentTimetable!.updateLectureAtIndex(index, lecture: oldLecture)
                failure()
        })
        STEventCenter.sharedInstance.postNotification(event: .CurrentTimetableChanged, object: nil)
    }
    
    func deleteLectureAtIndex(index: Int, object : AnyObject? ) {
        if currentTimetable == nil {
            return
        }
        let lecture = currentTimetable!.lectureList[index]
        currentTimetable?.deleteLectureAtIndex(index)
        // TODO: case when it fails
        STNetworking.deleteLecture(currentTimetable!, lecture: lecture, done: {}, failure: {})
        STEventCenter.sharedInstance.postNotification(event: STEvent.CurrentTimetableChanged, object: object)
    }
    
    
    //FIXME: Refactoring Needed
    func resetLecture(lecture: STLecture, done: ()->()) {
        if currentTimetable == nil {
            return
        }
        let index = currentTimetable!.lectureList.indexOf({ lec in
            return lec.id == lecture.id
        })!
        
        STNetworking.resetLecture(currentTimetable!, lecture: lecture, done: { newTimetable in
            self.currentTimetable?.lectureList = newTimetable.lectureList
            STEventCenter.sharedInstance.postNotification(event: .CurrentTimetableChanged, object: nil)
            done()
        }, failure: nil)
        STEventCenter.sharedInstance.postNotification(event: .CurrentTimetableChanged, object: nil)
    }
    
    func setTemporaryLecture(lecture :STLecture?, object : AnyObject? ) {
        if currentTimetable?.temporaryLecture == lecture {
            return
        }
        currentTimetable?.temporaryLecture = lecture
        STEventCenter.sharedInstance.postNotification(event: STEvent.CurrentTemporaryLectureChanged, object: object)
    }
}
