//
//  STTimetable.swift
//  SNUTT
//
//  Created by Rajin on 2016. 1. 6..
//  Copyright © 2016년 WaffleStudio. All rights reserved.
//

import Foundation

enum STAddLectureState {
    case success, errorTime, errorSameLecture
}

struct STTimetable: Codable {
    var lectureList : [STLecture] = []
    var quarter : STQuarter
    var title : String
    // TODO: id is not nullable
    var id : String? = ""

    var isLoaded : Bool {
        get {
            return !(id==nil)
        }
    }
    
    var totalCredit : Int {
        get {
            var ret : Int = 0
            for lecture in lectureList {
                ret += lecture.credit
            }
            return ret
        }
    }
    
    init(year aYear: Int, semester aSemester: STSemester, title aTitle: String) {
        self.quarter = STQuarter(year: aYear, semester: aSemester)
        self.title = aTitle
    }
    
    init(courseBook : STCourseBook, title: String) {
        self.quarter = courseBook.quarter
        self.title = title
    }

    private func canAddLecture(lectureList: [STLecture], lecture: STLecture) -> Bool {
        for it in lectureList {
            if it.isSameLecture(lecture) {
                return false
            }
            for class1 in it.classList {
                for class2 in lecture.classList {
                    if class1.time.isOverlappingWith(class2.time) {
                        return false
                    }
                }
            }
        }
        return true
    }
    
    mutating func addLecture(_ lecture : STLecture) -> STAddLectureState {
        for it in lectureList {
            if it.isSameLecture(lecture){
                return STAddLectureState.errorSameLecture
            }
            for class1 in it.classList {
                for class2 in lecture.classList {
                    if class1.time.isOverlappingWith(class2.time) {
                        return STAddLectureState.errorTime
                    }
                }
            }
        }
        lectureList.append(lecture)
        return STAddLectureState.success
    }

    func indexOf(lecture: STLecture) -> Int {
        for (index, it) in lectureList.enumerated() {
            if it.isSameLecture(lecture) {
                return index;
            }
        }
        return -1;
    }
    
    mutating func deleteLectureAtIndex(_ index: Int) {
        lectureList.remove(at: index)
    }
    mutating func deleteLecture(_ lecture: STLecture) {
        if let index = lectureList.index(of: lecture) {
            lectureList.remove(at: index)
        }
    }
    mutating func updateLectureAtIndex(_ index: Int, lecture :STLecture) {
        lectureList[index] = lecture
    }
    
    func timetableTimeMask() -> [Int] {
        return lectureList.reduce([0,0,0,0,0,0,0], { mask, lecture in
            return zip(mask, lecture.timeMask).map { t1, t2 in t1 | t2 }
        })
    }
    
    func timetableReverseTimeMask() -> [Int] {
        return timetableTimeMask().map {t1 in 0x3FFFFFFF ^ t1 }
    }

    private enum CodingKeys: String, CodingKey {
        case year
        case semester
        case title
        case _id
        case lecture_list
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(quarter.year, forKey: .year)
        try container.encode(quarter.semester, forKey: .semester)
        try container.encode(title, forKey: .title)
        try container.encode(id, forKey: ._id)
        try container.encode(lectureList, forKey: .lecture_list)
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let year = try container.decode(Int.self, forKey: .year)
        let semester = try container.decode(STSemester.self, forKey: .semester)
        quarter = STQuarter(year: year, semester: semester)
        title = (try? container.decode(String.self, forKey: .title)) ?? ""
        id = try container.decodeIfPresent(String.self, forKey: ._id)
        let lectures = (try container.decodeIfPresent([STLecture].self, forKey: .lecture_list)) ?? []
        lectures.forEach {
            self.addLecture($0)
        }
    }
}

extension STTimetable : Equatable {}

func ==(lhs: STTimetable, rhs: STTimetable) -> Bool {
    return lhs.quarter == rhs.quarter && lhs.title == rhs.title && lhs.id == rhs.id
}
