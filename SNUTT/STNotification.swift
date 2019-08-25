//
//  STNotification.swift
//  SNUTT
//
//  Created by Rajin on 2016. 3. 3..
//  Copyright © 2016년 WaffleStudio. All rights reserved.
//

import Foundation

struct STNotification {
    var type: STNotificationType
    var message: String
    var createdTime: Date?
    var url: String?
}

enum STNotificationType : Int, Codable {
    case Normal = 0, CourseBook, LectureUpdate, LectureRemove, Link
}

extension STNotification {
    var image: UIImage {
        switch type {
        case .Normal:
            return UIImage(named: "noticeWarning")!
        case .CourseBook:
            return UIImage(named: "noticeTimetable")!
        case .LectureUpdate:
            return UIImage(named: "noticeUpdate")!
        case .LectureRemove:
            return UIImage(named: "noticeTrash")!
        case .Link:
            return UIImage(named: "noticeInfo")!
        }
    }

    var createdFrom: String {
        if let createdTime = createdTime {
            return Date().offsetFrom(createdTime)
        } else {
            return ""
        }
    }
}

extension STNotification : Decodable {
    private enum CodingKeys: String, CodingKey {
        case message
        case type
        case created_at
        case createdFrom
        case detail
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        type = (try? container.decode(STNotificationType.self, forKey: .type)) ?? .Normal
        message = (try container.decodeIfPresent(String.self, forKey: .message)) ?? ""
        let createdAtStr = (try container.decodeIfPresent(String.self, forKey: .created_at)) ?? ""
        createdTime = STNotiUtil.parseDate(createdAtStr)
        url = (try? container.decode(String.self, forKey: .detail)) ?? nil
    }
}

class STNotiUtil {
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
