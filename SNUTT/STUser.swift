//
//  STUser.swift
//  SNUTT
//
//  Created by Rajin on 2016. 4. 3..
//  Copyright © 2016년 WaffleStudio. All rights reserved.
//

import Foundation

class STUser {
    var localId : String?
    var fbId : String?
    
    static var currentUser = STUser(localId: nil, fbId: nil);
    
    static func saveData() {
        if currentUser.fbId != nil {
            NSUserDefaults.standardUserDefaults().setObject(currentUser.fbId, forKey: "UserFBId")
        }
        if currentUser.localId != nil {
            NSUserDefaults.standardUserDefaults().setObject(currentUser.localId, forKey: "UserLocalId")
        }
    }
    
    static func loadData() {
        if let fbId = NSUserDefaults.standardUserDefaults().objectForKey("UserFBId") as? String {
            currentUser.fbId = fbId
        }
        if let localId = NSUserDefaults.standardUserDefaults().objectForKey("UserLocalId") as? String {
            currentUser.localId = localId
        }
    }
    
    init(localId : String?, fbId : String?) {
        self.localId = localId
        self.fbId = fbId
    }
    
    func isLogined() -> Bool {
        return localId != nil || fbId != nil
    }
    
}