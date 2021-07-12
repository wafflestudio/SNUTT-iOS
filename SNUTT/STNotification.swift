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
    var type: STNotificationType { get }
    var image: UIImage { get }
}

enum STNotificationType : Int {
    case Normal = 0, CourseBook, LectureUpdate, LectureRemove, Link
}

class STNotiUtil {
    static func parse(_ json: JSON) -> STNotification {
        let type = STNotificationType.init(rawValue: json["type"].intValue) ?? STNotificationType.Normal
        switch type {
        case .Normal:
            return STNormalNotification(json: json)
        case .CourseBook:
            return STCourseBookNotification(json: json)
        case .LectureUpdate:
            return STLectureUpdateNotification(json: json)
        case .LectureRemove:
            return STLectureRemoveNotification(json: json)
        case .Link:
            return STLinkNotification(json: json)
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
    let type = STNotificationType.Normal
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
    let type = STNotificationType.CourseBook
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
    let type = STNotificationType.LectureUpdate
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
    let type = STNotificationType.LectureRemove
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

struct STLinkNotification : STNotification {
    let message: String
    let createdTime: Date?
    let createdFrom: String
    let type = STNotificationType.Link
    let url: String?

    static let _image: UIImage = #imageLiteral(resourceName: "noticeInfo")
    var image: UIImage {
        get {
            return STLinkNotification._image
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
        url = json["detail"].string
    }
}

extension STNotification {
    var notificationTitle: String {
        switch type {
        case .CourseBook:
            return "추가"
        case .Normal:
            return "업데이트"
        case .LectureUpdate:
            return "업데이트"
        case .LectureRemove:
            return "삭제"
        case .Link:
            return "공지"
        }
    }
}
