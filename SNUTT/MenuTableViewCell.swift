//
//  MenuTableViewCell.swift
//  SNUTT
//
//  Created by Jinsup Keum on 2021/07/05.
//  Copyright © 2021 WaffleStudio. All rights reserved.
//

import UIKit

protocol MenuTableViewCellDelegate: class {
    func showSettingSheet(_ cell: MenuTableViewCell)
}

class MenuTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    var delegate: MenuTableViewCellDelegate?
    
    @IBOutlet weak var credits: UILabel!
    @IBOutlet weak var timetableLabel: UILabel!
    @IBOutlet weak var checkedIcon: UIImageView!
    
    @IBAction func duplicateButton(_ sender: UIButton) {
    }
    
    @IBAction func settingButton(_ sender: UIButton) {
        delegate?.showSettingSheet(self)
    }
    
    @IBOutlet weak var duplicateBButton: UIButton!
    @IBOutlet weak var settingBButton: UIButton!
    
    func checkCurrentTimetable() {
        checkedIcon.image = UIImage(systemName: "circle.fill")
        checkedIcon.tintColor = .red
    }
    
    func setLabel(text: String) {
        timetableLabel.text = text
    }
    
    func setCredit(credit: Int) {
        credits.text = "(" + String(credit) + " 학점)"
    }
    
    func setCreateNewCellStyle() {
        credits.isHidden = true
        checkedIcon.isHidden = true
        timetableLabel.textColor = .gray
        duplicateBButton.isHidden = true
        settingBButton.isHidden = true
    }
    
    func hideCheckIcon() {
        checkedIcon.isHidden = true
    }
}
