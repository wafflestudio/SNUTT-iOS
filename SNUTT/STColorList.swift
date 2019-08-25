//
//  STColorList.swift
//  SNUTT
//
//  Created by Rajin on 2017. 3. 17..
//  Copyright © 2017년 WaffleStudio. All rights reserved.
//

import Foundation

struct STColorList : Codable {

    var colorList : [STColor] = []
    var nameList : [String] = []

    init(colorList: [STColor], nameList: [String]) {
        if (colorList.count != nameList.count || colorList.count == 0) {
            self.colorList = [STColor()]
            self.nameList = ["회색"]
        } else {
            self.colorList = colorList
            self.nameList = nameList
        }
    }
}
