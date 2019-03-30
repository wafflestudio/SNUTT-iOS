//
//  STCourseBook.swift
//  SNUTT
//
//  Created by Rajin on 2016. 1. 8..
//  Copyright © 2016년 WaffleStudio. All rights reserved.
//

import Foundation
import SwiftyJSON

struct STCourseBook : DictionaryRepresentable, Codable {
    var quarter : STQuarter
    
    init (year aYear : Int, semester aSemester : STSemester) {
        self.quarter = STQuarter(year: aYear, semester: aSemester)
    }
    
    init (json: JSON) {
        let year = json["year"].intValue
        let semester = STSemester(rawValue: json["semester"].intValue)!
        self.init(year: year, semester: semester)
    }
    
    //MARK: DictionaryRepresentable
    
    func dictionaryValue() -> NSDictionary {
        return self.quarter.dictionaryValue()
    }
    init?(dictionary: NSDictionary?) {
        guard let quarter = STQuarter(dictionary: dictionary) else { return nil }
        self.quarter = quarter
    }

    private enum CodingKeys: String, CodingKey {
        case year
        case semester
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(quarter.year, forKey: .year)
        try container.encode(quarter.semester, forKey: .semester)
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let year = try container.decode(Int.self, forKey: .year)
        let semester = try container.decode(STSemester.self, forKey: .semester)
        quarter = STQuarter(year: year, semester: semester)
    }
}

extension STCourseBook : Equatable {}

func ==(lhs: STCourseBook, rhs: STCourseBook) -> Bool {
    return lhs.quarter == rhs.quarter
}
