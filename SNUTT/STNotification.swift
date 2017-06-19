//
//  STNotification.swift
//  SNUTT
//
//  Created by Rajin on 2016. 3. 3..
//  Copyright © 2016년 WaffleStudio. All rights reserved.
//

import Foundation
import SwiftyJSON

protocol STNotification {
    var message: String { get }
    var createdTime: Date? { get }
    var createdFrom: String { get }
    var type: Int { get }
    var image: UIImage { get }
}

class STNotiUtil {
    static func parse(_ json: JSON) -> STNotification {
        switch json["type"].intValue {
        case 0:
            return STNormalNotification(json: json)
        case 1:
            return STCourseBookNotification(json: json)
        case 2:
            return STLectureUpdateNotification(json: json)
        case 3:
            return STLectureRemoveNotification(json: json)
        default:
            return STNormalNotification(json: json)
        }
    }
    
    static fileprivate func getDateFormatter() -> DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
        return dateFormatter
    }
    
    static let dateFormatter = STNotiUtil.getDateFormatter()
    
    static open func parseDate(_ str: String) -> Date? {
        return STNotiUtil.dateFormatter.date(from: str)
    }
}

struct STNormalNotification : STNotification {
    let message: String
    let createdTime: Date?
    let createdFrom: String
    let type: Int = 0
    static let _image: UIImage = #imageLiteral(resourceName: "noticeWarning")
    var image: UIImage {
        get {
            return STNormalNotification._image
        }
    }
    init(json : JSON) {
        message = json["message"].stringValue
        createdTime = STNotiUtil.parseDate(json["created_at"].stringValue)
        if (createdTime != nil) {
            createdFrom = Date().offsetFrom(createdTime!)
        } else {
            createdFrom = ""
        }
    }
}

struct STCourseBookNotification : STNotification {
    let message: String
    let createdTime: Date?
    let createdFrom: String
    let type: Int = 1
    static let _image: UIImage = #imageLiteral(resourceName: "noticeTimetable")
    var image: UIImage {
        get {
            return STCourseBookNotification._image
        }
    }
    init(json : JSON) {
        message = json["message"].stringValue
        createdTime = STNotiUtil.parseDate(json["created_at"].stringValue)
        if (createdTime != nil) {
            createdFrom = Date().offsetFrom(createdTime!)
        } else {
            createdFrom = ""
        }
    }
}

struct STLectureUpdateNotification : STNotification {
    let message: String
    let createdTime: Date?
    let createdFrom: String
    let type: Int = 2
    static let _image: UIImage = #imageLiteral(resourceName: "noticeUpdate")
    var image: UIImage {
        get {
            return STLectureUpdateNotification._image
        }
    }
    init(json : JSON) {
        message = json["message"].stringValue
        createdTime = STNotiUtil.parseDate(json["created_at"].stringValue)
        if (createdTime != nil) {
            createdFrom = Date().offsetFrom(createdTime!)
        } else {
            createdFrom = ""
        }
    }
}

struct STLectureRemoveNotification : STNotification {
    let message: String
    let createdTime: Date?
    let createdFrom: String
    let type: Int = 3
    static let _image: UIImage = #imageLiteral(resourceName: "noticeTrash")
    var image: UIImage {
        get {
            return STLectureRemoveNotification._image
        }
    }
    init(json : JSON) {
        message = json["message"].stringValue
        createdTime = STNotiUtil.parseDate(json["created_at"].stringValue)
        if (createdTime != nil) {
            createdFrom = Date().offsetFrom(createdTime!)
        } else {
            createdFrom = ""
        }
    }
}
