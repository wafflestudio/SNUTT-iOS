//
//  STLecture.swift
//  SNUTT
//
//  Created by 김진형 on 2015. 7. 2..
//  Copyright (c) 2015년 WaffleStudio. All rights reserved.
//

import Foundation

struct STLecture {
    var classification : String?
    var department : String?
    var academicYear : String?
    var courseNumber : String?
    var lectureNumber : String?
    var title : String = ""
    var credit : Int = 0
    var instructor : String = ""
    var quota : Int?
    var remark : String?
    var category : String?
    var id : String?
    var classList :[STSingleClass] = []
    var color : STColor? = nil
    var colorIndex: Int = 0
    var timeMask: [Int] = []

    func getColor() -> STColor {
        // TODO: need some thinking about this
        #if TODAY_EXTENSION
            let colorManager = STTodayColorManager.sharedInstance
        #else
            let colorManager = AppContainer.resolver.resolve(STColorManager.self)!
        #endif
        let colorList = colorManager.colorList
        if colorIndex == 0 {
            return color ?? STColor()
        } else if (colorIndex <= colorList.colorList.count && colorIndex >= 1) {
            return colorList.colorList[colorIndex - 1]
        } else {
            return STColor()
        }
    }

    var timeDescription : String {
        var ret: String = ""
        for it in classList {
            ret = ret + "/" + it.time.startString()
        }
        if ret != "" {
            ret = ret.substring(from: ret.characters.index(ret.startIndex, offsetBy: 1))
        } else {
            ret = "(없음)"
        }
        return ret
    }
    
    var placeDescription : String {
        var ret: String = ""
        for it in classList {
            ret = ret + "/" + it.place
        }
        if ret != "" {
            ret = ret.substring(from: ret.characters.index(ret.startIndex, offsetBy: 1))
        } else {
            ret = "(없음)"
        }
        return ret
    }
    
    var tagDescription : String {
        var ret: String = ""
        if category != nil && category != ""{
            ret = ret + ", " + category!
        }
        if department != nil && department != "" {
            ret = ret + ", " + department!
        }
        if academicYear != nil && academicYear != "" {
            ret = ret + ", " + academicYear!
        }
        if ret != "" {
            ret = ret.substring(from: ret.characters.index(ret.startIndex, offsetBy: 2))
        } else {
            ret = "(없음)"
        }
        return ret
    }
    
    init() {
    }
    
    func isSameLecture(_ right : STLecture) -> Bool {
        return (courseNumber == right.courseNumber && lectureNumber == right.lectureNumber) && courseNumber != nil && lectureNumber != nil
    }
}

extension STLecture: Codable {
    private enum CodingKeys: String, CodingKey {
        case classification
        case department
        case academic_year
        case course_number
        case lecture_number
        case course_title
        case credit
        case instructor
        case quota
        case remark
        case category
        case _id
        case class_time_json
        case class_time_mask
        case color
        case colorIndex
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(classification, forKey: .classification)
        try container.encodeIfPresent(department, forKey: .department)
        try container.encodeIfPresent(academicYear, forKey: .academic_year)
        try container.encodeIfPresent(courseNumber, forKey: .course_number)
        try container.encode(title, forKey: .course_title)
        try container.encodeIfPresent(credit, forKey: .credit)
        try container.encodeIfPresent(instructor, forKey: .instructor)
        try container.encodeIfPresent(quota, forKey: .quota)
        try container.encodeIfPresent(remark, forKey: .remark)
        try container.encodeIfPresent(category, forKey: .category)
        try container.encode(timeMask, forKey: .class_time_mask)
        try container.encodeIfPresent(id, forKey: ._id)
        try container.encodeIfPresent(colorIndex, forKey: .colorIndex)
        try container.encodeIfPresent(color, forKey: .color)
        try container.encode(classList, forKey: .class_time_json)
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        classification = try container.decodeIfPresent(String.self, forKey: .classification)
        department = try container.decodeIfPresent(String.self, forKey: .department)
        academicYear = try container.decodeIfPresent(String.self, forKey: .academic_year)
        courseNumber = try container.decodeIfPresent(String.self, forKey: .course_number)
        title = try container.decode(String.self, forKey: .course_title)
        credit = (try container.decodeIfPresent(Int.self, forKey: .credit)) ?? 0
        instructor = (try container.decodeIfPresent(String.self, forKey: .instructor)) ?? ""
        quota = (try container.decodeIfPresent(Int.self, forKey: .quota)) ?? 0
        remark = try container.decodeIfPresent(String.self, forKey: .remark)
        category = try container.decodeIfPresent(String.self, forKey: .category)
        timeMask = try container.decode([Int].self, forKey: .class_time_mask)
        id = try container.decodeIfPresent(String.self, forKey: ._id)
        colorIndex = (try container.decodeIfPresent(Int.self, forKey: .colorIndex)) ?? 0
        color = try? container.decode(STColor.self, forKey: .color)
        classList = try container.decode([STSingleClass].self, forKey: .class_time_json)
    }
}

extension STLecture : Equatable {}

func ==(lhs: STLecture, rhs: STLecture) -> Bool {
    return lhs.classification == rhs.classification
        && lhs.department == rhs.department
        && lhs.academicYear == rhs.academicYear
        && lhs.courseNumber == rhs.courseNumber
        && lhs.lectureNumber == rhs.lectureNumber
        && lhs.title == rhs.title
        && lhs.credit == rhs.credit
        && lhs.instructor == rhs.instructor
        && lhs.quota == rhs.quota
        && lhs.remark == rhs.remark
        && lhs.category == rhs.category
        && lhs.id == rhs.id
        && lhs.classList == rhs.classList
        && lhs.color == rhs.color
        && lhs.colorIndex == rhs.colorIndex
}
