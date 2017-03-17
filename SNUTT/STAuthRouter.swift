//
//  STAuthRouter.swift
//  SNUTT
//
//  Created by Rajin on 2016. 1. 13..
//  Copyright © 2016년 WaffleStudio. All rights reserved.
//

import Foundation
import Alamofire

enum STAuthRouter : STRouter {
    
    static let baseURLString : String = STConfig.sharedInstance.baseURL+"/auth"
    static let shouldAddToken: Bool = false
    
    case LocalLogin(id: String, password: String)
    case LocalRegister(id: String, password: String, email: String?)
    case FBRegister(id: String, token: String)
    
    //MARK: STRouter
    
    var method: Alamofire.Method {
        switch self {
        case .LocalLogin:
            return .POST
        case .LocalRegister:
            return .POST
        case .FBRegister:
            return .POST
        }
    }
    
    var path: String {
        switch self {
        case .LocalLogin:
            return "/login_local"
        case .LocalRegister:
            return "/register_local"
        case .FBRegister:
            return "/login_fb"
        }
    }
    
    var parameters: [String : AnyObject]? {
        switch self {
        case .LocalLogin(let id, let password):
            return ["id" : id, "password" : password]
        case let .LocalRegister(id, password, email):
            var ret = ["id" : id, "password" : password]
            if let email = email {
                ret["email"] = email
            }
            return ret
        case let .FBRegister(id, token):
            return ["fb_id" : id, "fb_token" : token]
        }
    }
    
}
