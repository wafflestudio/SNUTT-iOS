//
//  STTagList.swift
//  SNUTT
//
//  Created by Rajin on 2016. 3. 6..
//  Copyright © 2016년 WaffleStudio. All rights reserved.
//

import Foundation

struct STTagList : Codable {
    var quarter : STQuarter
    var tagList : [STTag]
    var updatedTime: Int64
}
