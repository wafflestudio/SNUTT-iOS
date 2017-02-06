//
//  STSearchRouter.swift
//  SNUTT
//
//  Created by Rajin on 2016. 1. 24..
//  Copyright © 2016년 WaffleStudio. All rights reserved.
//

import Foundation
import Alamofire

enum STSearchRouter : STRouter {
    
    static let baseURLString = STConfig.sharedInstance.baseURL+"/search_query"
    static let shouldAddToken: Bool = true
    
    case Search(query : String, tagList: [STTag], mask: [Int]?, offset: Int, limit: Int)
    
    var method: Alamofire.Method {
        switch self {
        case .Search:
            return .POST
        }
    }
    
    var path: String {
        switch self {
        case .Search:
            return ""
        }
    }
    
    var parameters: [String : AnyObject]? {
        switch self {
        case let .Search(query, tagList, mask, offset, limit):
            // FIXME: is there better way?
            let year = STTimetableManager.sharedInstance.currentTimetable?.quarter.year ?? 0
            let semester = STTimetableManager.sharedInstance.currentTimetable?.quarter.semester ?? STSemester.First
            var credit : [Int] = []
            var instructor : [String] = []
            var department : [String] = []
            var academicYear : [String] = []
            var classification : [String] = []
            var category : [String] = []
            for tag in tagList {
                switch tag.type {
                case .Credit:
                    credit.append(Int(tag.text.stringByTrimmingCharactersInSet(NSCharacterSet.decimalDigitCharacterSet().invertedSet))!)
                case .Department:
                    department.append(tag.text)
                case .Instructor:
                    instructor.append(tag.text)
                case .AcademicYear:
                    academicYear.append(tag.text)
                case .Classification:
                    classification.append(tag.text)
                case .Category:
                    category.append(tag.text)
                }
            }
            var parameters : [String : AnyObject] = [
                "title" : query,
                "year" : year,
                "semester" : semester.rawValue,
                "credit" : credit,
                "instructor" : instructor,
                "department" : department,
                "academic_year" : academicYear,
                "classification" : classification,
                "category" : category,
                "offset": offset,
                "limit" : limit
            ]
            if (mask != nil) {
                parameters["time_mask"] = mask
            }
            return parameters
        }
    }
    
}
