//
//  STTargets.swift
//  SNUTT
//
//  Created by Rajin on 2018. 12. 29..
//  Copyright © 2018년 WaffleStudio. All rights reserved.
//

import Foundation
import Moya

struct STTarget {
    // MARK: /auth
    struct LocalLogin: STTargetType {
        let params: Params
        let path = "/auth/login_local"
        let method: Moya.Method = .post
        struct Params: Codable {
            var id : String
            var password: String
        }
        struct Result: Codable {
            var token: String
            var user_id: String
        }
    }

    struct LocalRegister: STTargetType {
        let params: Params
        let path = "/auth/register_local"
        let method: Moya.Method = .post
        struct Params: Codable {
            var id: String
            var password: String
            var email: String? = nil
        }
        struct Result: Codable {
            var token: String
            var user_id: String
        }
    }

    struct FBRegister: STTargetType {
        let params: Params
        let path = "/auth/login_fb"
        let method: Moya.Method = .post
        struct Params: Codable {
            var fb_id: String
            var fb_token: String
        }
        struct Result: Codable {
            var token: String
            var user_id: String
        }
    }

    struct LogOutDevice: STTargetType {
        let params: Params
        let path = "/auth/logout"
        let method: Moya.Method = .post
        struct Params: Codable {
            var user_id: String
            var registration_id: String
        }
        struct Result: Codable {
        }
    }

    // MARK: /tables

    struct GetTimetableList: STTargetType {
        let params = Params()
        let path = "/tables"
        let method: Moya.Method = .get
        struct Params: Codable {}
        typealias Result = [STTimetable]
    }

    struct GetTimetable: STTargetType {
        let params = Params()
        var path : String {
            return "/tables/\(id)"
        }
        let method: Moya.Method = .get
        var id: String
        struct Params: Codable {}
        typealias Result = STTimetable
    }

    struct CreateTimetable: STTargetType {
        let params: Params
        let path = "/tables"
        let method: Moya.Method = .post
        struct Params: Codable {
            var title: String
            var year: Int
            var semester: STSemester
        }
        typealias Result = [STTimetable]
    }

    struct UpdateTimetable: STTargetType {
        let params: Params
        var path : String {
            return "/tables/\(id)"
        }
        let method: Moya.Method = .put
        var id: String
        struct Params: Codable {
            var title: String
        }
        struct Result: Codable {}
    }

    struct DeleteTimetable: STTargetType {
        let params = Params()
        var path : String {
            return "/tables/\(id)"
        }
        let method: Moya.Method = .delete
        var id: String
        struct Params: Codable {}
        struct Result: Codable {
            // DAVID
        }
    }

    struct GetRecentTimetable: STTargetType {
        let params = Params()
        let path = "/tables/recent"
        let method: Moya.Method = .get
        struct Params: Codable {}
        typealias Result = STTimetable
    }

    struct AddCustomLecture: STTargetType {
        let params: Params
        var path : String {
            return "/tables/\(timetableId)/lecture"
        }
        let method: Moya.Method = .post
        var timetableId: String
        struct Params: Codable {
            var classification : String?
            var department: String?
            var academic_year: String?
            var course_number: String?
            var lecture_number: String?
            var course_title: String
            var credit: Int
            var instructor: String
            var quota: Int?
            var remark: String?
            var category: String?
            var class_time_json: [STSingleClass]
            var color: STColor?
            var colorIndex: Int
        }
        typealias Result = STTimetable
    }

    struct AddLecture: STTargetType {
        let params = Params()
        var path: String {
            return "/tables/\(timetableId)/lecture/\(lectureId)"
        }
        let method: Moya.Method = .post
        var timetableId: String
        var lectureId: String
        struct Params: Codable {}
        typealias Result = STTimetable
    }

    struct DeleteLecture: STTargetType {
        let params = Params()
        var path: String {
            return "/tables/\(timetableId)/lecture/\(lectureId)"
        }
        let method: Moya.Method = .delete
        var timetableId: String
        var lectureId: String
        struct Params: Codable {}
        typealias Result = STTimetable
    }

    struct UpdateLecture: STTargetType {
        var params: Params
        var path: String {
            return "/tables/\(timetableId)/lecture/\(lectureId)"
        }
        let method: Moya.Method = .put
        var timetableId: String
        var lectureId: String
        struct Params: Codable {
            var classification : String??
            var department: String??
            var academic_year: String??
            var course_number: String??
            var lecture_number: String??
            var course_title: String?
            var credit: Int?
            var instructor: String?
            var quota: Int??
            var remark: String??
            var category: String??
            var class_time_json: [STSingleClass]?
            var color: STColor??
            var colorIndex: Int?
        }
        typealias Result = STTimetable
    }

    struct ResetLecture: STTargetType {
        let params = Params()
        var path: String {
            return "/tables/\(timetableId)/lecture/\(lectureId)/reset"
        }
        let method: Moya.Method = .put
        var timetableId: String
        var lectureId: String
        struct Params: Codable {}
        typealias Result = STTimetable
    }

    // MARK: /search_query

    struct SearchLectures: STTargetType {
        let params: Params
        let path = "/search_query"
        let method: Moya.Method = .post
        struct Params: Codable {
            var title: String
            var year: Int
            var semester: STSemester
            var credit: [Int]
            var instructor: [String]
            var department: [String]
            var academic_year: [String]
            var classification: [String]
            var category: [String]
            var offset: Int
            var limit: Int
        }

        typealias Result = [STLecture]
    }

    // MARK: /tags
    struct GetTagListUpdateTime: STTargetType {
        let params = Params()
        var path : String {
            return "/tags/\(year)/\(semester.rawValue)/update_time"
        }
        let method: Moya.Method = .get
        var year: Int
        var semester: STSemester
        struct Params: Codable {}
        struct Result: Codable {
            var updated_at: Int64
            // TODO: remove this.. this is here for server bug.
            private enum CodingKeys: String, CodingKey {
                case updated_at
            }

            func encode(to encoder: Encoder) throws {
                throw "Not Supported"
            }

            init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                updated_at = (try? container.decode(Int64.self, forKey: .updated_at)) ?? 0
            }
        }
    }

    struct GetTagList: STTargetType {
        let params = Params()
        var path : String {
            return "/tags/\(year)/\(semester.rawValue)"
        }
        let method: Moya.Method = .get
        var year: Int
        var semester: STSemester
        struct Params: Codable {}
        struct Result: Codable {
            var classification: [String]?
            var department: [String]?
            var academic_year: [String]?
            var credit: [String]?
            var instructor: [String]?
            var category: [String]?
            var updated_at: Int64
            // TODO: remove this.. this is here for server bug.
            private enum CodingKeys: String, CodingKey {
                case classification
                case department
                case academic_year
                case credit
                case instructor
                case category
                case updated_at
            }

            func encode(to encoder: Encoder) throws {
                throw "Not Supported"
            }

            init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                classification = try container.decodeIfPresent([String].self, forKey: .classification)
                department = try container.decodeIfPresent([String].self, forKey: .department)
                academic_year = try container.decodeIfPresent([String].self, forKey: .academic_year)
                credit = try container.decodeIfPresent([String].self, forKey: .credit)
                instructor = try container.decodeIfPresent([String].self, forKey: .instructor)
                category = try container.decodeIfPresent([String].self, forKey: .category)
                updated_at = (try? container.decode(Int64.self, forKey: .updated_at)) ?? 0
            }
        }
    }

    // MARK: /notification

    struct GetNotificationList: STTargetType {
        let params: Params
        let path = "/notification"
        let method: Moya.Method = .get
        struct Params: Codable {
            var limit: Int
            var offset: Int
            var explicit: Bool? = nil
        }
        typealias Result = [STNotification]
    }

    struct GetNotificationCount: STTargetType {
        let params = Params()
        let path = "/notification/count"
        let method: Moya.Method = .get
        struct Params: Codable {}
        struct Result: Codable {
            var count: Int
        }
    }

    // MARK: /user

    struct GetUser: STTargetType {
        let params = Params()
        let path = "/user/info"
        let method: Moya.Method = .get
        struct Params: Codable {}
        typealias Result = STUser
    }

    struct EditUser: STTargetType {
        let params: Params
        let path = "/user/info"
        let method: Moya.Method = .put
        struct Params: Codable {
            var email: String
        }
        struct Result: Codable {}
    }

    struct ChangePassword: STTargetType {
        let params: Params
        let path = "/user/password"
        let method: Moya.Method = .put
        struct Params: Codable {
            var old_password: String
            var new_password: String
        }
        struct Result: Codable {
            var token: String
        }
    }

    struct AddLocalId: STTargetType {
        let params: Params
        let path = "/user/password"
        let method: Moya.Method = .post
        struct Params: Codable {
            var id: String
            var password: String
        }
        struct Result: Codable {
            var token: String
        }
    }

    struct AddFacebook: STTargetType {
        let params: Params
        let path = "/user/facebook"
        let method: Moya.Method = .post
        struct Params: Codable {
            var fb_id: String
            var fb_token: String
        }
        struct Result: Codable {}
    }

    struct DetachFacebook: STTargetType {
        let params = Params()
        let path = "/user/facebook"
        let method: Moya.Method = .delete
        struct Params: Codable {}
        struct Result: Codable {}
    }

    struct GetFacebook: STTargetType {
        let params = Params()
        let path = "/user/facebook"
        let method: Moya.Method = .get
        struct Params: Codable {}
        struct Result: Codable {

        }
    }

    struct AddDevice: STTargetType {
        let params = Params()
        var path : String {
            return "/user/device/\(id)"
        }
        let method: Moya.Method = .post
        var id: String
        struct Params: Codable {}
        struct Result: Codable {}
    }

    struct DeleteDevice: STTargetType {
        let params = Params()
        var path : String {
            return "/user/device/\(id)"
        }
        let method: Moya.Method = .delete
        var id: String
        struct Params: Codable {}
        struct Result: Codable {

        }
    }

    struct DeleteUser: STTargetType {
        let params = Params()
        let path = "/user/account"
        let method: Moya.Method = .delete
        struct Params: Codable {}
        struct Result: Codable {

        }
    }

    // MARK: /course_books

    struct GetCourseBookList: STTargetType {
        let params = Params()
        let path = "/course_books"
        let method: Moya.Method = .get
        struct Params: Codable {}
        typealias Result = [STCourseBook]
    }

    struct GetRecentCourseBook: STTargetType {
        let params = Params()
        let path = "/course_books/recent"
        let method: Moya.Method = .get
        struct Params: Codable {}
        struct Result: Codable {

        }
    }

    struct GetSyllabus: STTargetType {
        let params: Params
        let path = "/course_books/official"
        let method: Moya.Method = .get
        struct Params: Codable {
            var year: Int
            var semester: STSemester
            var course_number: String
            var lecture_number: String
        }
        struct Result: Codable {
            var url : String?
        }
    }

    // MARK: etcs

    struct SendFeedback: STTargetType {
        let params: Params
        let path = "/feedback"
        let method: Moya.Method = .post
        struct Params: Codable {
            var message: String
            var email: String?
        }
        struct Result: Codable {}
    }

    struct GetColorList: STTargetType {
        let params = Params()
        let path = "/colors/vivid_ios"
        let method: Moya.Method = .get
        struct Params: Codable {}
        struct Result: Codable {
            var colors: [STColor]
            var names: [String]
        }
    }

    // MARK: AppVersion

    struct CheckLatestAppVersion: STTargetType {
        var baseURL: URL {
            return URL(string: "http://itunes.apple.com/kr")!
        }
        let params = Params()
        let path = "/lookup"
        let method: Moya.Method = .get
        struct Params: Codable {
            var bundleId: String = Bundle.main.bundleIdentifier!
        }
        struct Result: Codable {
            var results: [VersionResult]
            struct VersionResult: Codable {
                var version: String?
            }
        }
    }
}

