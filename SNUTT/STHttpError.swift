//
//  STHttpError.swift
//  SNUTT
//
//  Created by Rajin on 2018. 12. 29..
//  Copyright © 2018년 WaffleStudio. All rights reserved.
//

import Foundation
import Moya

enum STHttpError: Error {
    case networkError
    case errorCode(STErrorCode)
    case decode(Error)
    case moya(MoyaError)

    var localizedDescription: String {
        switch self {
        case .networkError:
            return "네트워크 환경이 원활하지 않습니다."
        case .errorCode(let errorCode):
            return errorCode.errorMessage
        case .decode(let error):
            return "decode error : " + error.localizedDescription
        case .moya(let error):
            return error.localizedDescription
        }
    }
}
