//
//  STTagSearchInfoView.swift
//  SNUTT
//
//  Created by Rajin on 2017. 6. 11..
//  Copyright © 2017년 WaffleStudio. All rights reserved.
//

import UIKit

class STTagSearchInfoView: UIView {

    @IBOutlet weak var closeViewButton: STViewButton!
    weak var searchController: STLectureSearchTableViewController!
    
    override func awakeFromNib() {
        closeViewButton.buttonPressAction = {
            self.searchController.showInfo = false
            self.searchController.tableView.reloadEmptyDataSet();
        }
    }
}
