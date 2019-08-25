//
//  STEventCenter.swift
//  SNUTT
//
//  Created by Rajin on 2016. 1. 10..
//  Copyright © 2016년 WaffleStudio. All rights reserved.
//

import Foundation

enum STEvent : String {
    case CourseBookUpdated = "CourseBookUpdated"
    case TagListUpdated = "TagListUpdated"
    case UserUpdated = "UserUpdated"
    case ColorListUpdated = "ColorListUpdated"
}

class STEventCenter : NotificationCenter {
    
    // MARK: Singleton
    
    fileprivate static var sharedEventCenter : STEventCenter? = nil
    
    static var sharedInstance : STEventCenter {
        get {
            if sharedEventCenter == nil {
                sharedEventCenter = STEventCenter()
            }
            return sharedEventCenter!
        }
    }
    fileprivate override init() {
        super.init()
    }
    
    func addObserver(_ observer: AnyObject, selector aSelector: Selector, event aEvent : STEvent, object anObject: AnyObject?) {
        self.addObserver(observer, selector: aSelector, name: NSNotification.Name(rawValue: aEvent.rawValue), object: anObject)
    }
    
    func postNotification(event aEvent : STEvent, object anObject: AnyObject?) {
        self.post(name: Notification.Name(rawValue: aEvent.rawValue), object: anObject)
    }
    
}
