//
//  STTarget.swift
//  SNUTT
//
//  Created by Rajin on 2018. 8. 26..
//  Copyright © 2018년 WaffleStudio. All rights reserved.
//

import Foundation
import Moya
import Alamofire

protocol STTargetType: TargetType {
    associatedtype Result: Decodable
    associatedtype Params: Encodable
    var params: Params { get }
}

extension STTargetType {
    var baseURL: URL {
        let serverURL = STConfig.sharedInstance.baseURL
        // swiftlint:disable force_unwrapping
        return URL(string: serverURL)!
        // swiftlint:enable force_unwrapping
    }

    var validationType: ValidationType {
        return ValidationType.successAndRedirectCodes
    }

    var sampleData: Data {
        return Data()
    }

    var task: Task {
        switch self.method {
        case .get:
            let dict = (try? params.asDictionary()) ?? [:]
            return .requestParameters(parameters: dict, encoding: URLEncoding.queryString)
        default:
            return Task.requestJSONEncodable(params)
        }
    }
    
    var headers: [String: String]? {
        return ["Content-type": "application/json"]
    }
}
