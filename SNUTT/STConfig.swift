//
//  STConfig.swift
//  SNUTT
//
//  Created by Rajin on 2016. 1. 13..
//  Copyright © 2016년 WaffleStudio. All rights reserved.
//

import Foundation
import Alamofire

class STConfig {
    // MARK: Singleton
    
    fileprivate static var sharedConfig : STConfig? = nil
    
    static var sharedInstance : STConfig {
        get {
            if sharedConfig == nil {
                sharedConfig = STConfig()
            }
            return sharedConfig!
        }
    }

    fileprivate init() {
        // FIXME: we only use production since there is no test server.
        #if DEBUG
        let configKey = "production"
        #elseif PRODUCTION
        let configKey = "production"
        #else
        let configKey = "production"
        #endif

        let path = Bundle.main.path(forResource: "config", ofType: "plist")!
        let configAllDict = NSDictionary(contentsOfFile: path)!
        let configDict = configAllDict.object(forKey: configKey) as! NSDictionary

        baseURL = configDict.object(forKey: "api_server_url") as! String
        apiKey = configDict.object(forKey: "api_key") as! String
    }

    let baseURL : String
    let apiKey : String
}
