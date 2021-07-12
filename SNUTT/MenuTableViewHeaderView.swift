//
//  MenuTableViewHeaderView.swift
//  SNUTT
//
//  Created by Jinsup Keum on 2021/07/07.
//  Copyright © 2021 WaffleStudio. All rights reserved.
//

import UIKit

protocol MenuTableViewHeaderViewDelegate: class {
    func presentSemesterPickView(_: MenuTableViewHeaderView)
}

class MenuTableViewHeaderView: UITableViewHeaderFooterView {
    
    weak var delegate: MenuTableViewHeaderViewDelegate?
    
    @IBAction func chooseSemester(_ sender: UIButton) {
        delegate?.presentSemesterPickView(self)
    }
    
    @IBOutlet weak var headerLabel: UILabel!
    
    func setHeaderLabel(text: String) {
        headerLabel.text = text
    }
}
