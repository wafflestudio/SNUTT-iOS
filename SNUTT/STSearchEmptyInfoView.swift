//
//  STSearchEmptyInfoView.swift
//  SNUTT
//
//  Created by Rajin on 2017. 6. 11..
//  Copyright © 2017년 WaffleStudio. All rights reserved.
//

import UIKit

class STSearchEmptyInfoView: UIView {

    @IBOutlet weak var helpViewButton: STViewButton!
    @IBOutlet weak var searchIcon: UIImageView!
    weak var searchController: STLectureSearchTableViewController!

    override func awakeFromNib() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleIconTap))
        searchIcon.addGestureRecognizer(tapGesture)
        searchIcon.isUserInteractionEnabled = true
        helpViewButton.buttonPressAction = { 
            self.searchController.showInfo = true
            self.searchController.tableView.reloadEmptyDataSet()
        }
    }

    @objc func handleIconTap(sender: UITapGestureRecognizer) {
        searchController.setFocusToSearch()
    }
}
