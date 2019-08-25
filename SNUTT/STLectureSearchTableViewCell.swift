//
//  STLectureSearchTableViewCell.swift
//  SNUTT
//
//  Created by 김진형 on 2015. 7. 3..
//  Copyright (c) 2015년 WaffleStudio. All rights reserved.
//

import UIKit
import MarqueeLabel

class STLectureSearchTableViewCell: UITableViewCell, UIAlertViewDelegate {

    @IBOutlet weak var titleLabel: MarqueeLabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var profLabel: UILabel!
    @IBOutlet weak var tagLabel: MarqueeLabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var placeLabel: UILabel!
    @IBOutlet weak var addButton: STViewButton!
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var addButtonLabel: UILabel!
    weak var tableView : UITableView!

    @IBOutlet weak var constraintForHidden: NSLayoutConstraint!
    @IBOutlet weak var constraintForShown: NSLayoutConstraint!

    let timetableManager = AppContainer.resolver.resolve(STTimetableManager.self)!

    func indexInTimetable() -> Int {
        guard let lecture = lecture else {
            return -1
        }
        let index = timetableManager.currentTimetable?.indexOf(lecture: lecture) ?? -1
        return index
    }

    var lecture : STLecture? {
        didSet {
            titleLabel.text = lecture!.title == "" ? "강좌명" : lecture!.title
            titleLabel.textColor = lecture!.title == "" ? UIColor(white: 1.0, alpha: 0.7) : UIColor(white: 1.0, alpha: 1.0)
            if self.isSelected {
                tagLabel.text = lecture!.remark == "" ? lecture!.tagDescription : lecture!.remark
            } else {
                tagLabel.text = lecture!.tagDescription
            }
            timeLabel.text = lecture!.timeDescription
            placeLabel.text = lecture!.placeDescription
            setAddButton()
            setDescLabel()
        }
    }

    func setDescLabel() {
        guard let lecture = lecture else {
            return
        }
        profLabel.text = lecture.instructor
        descriptionLabel.text = (lecture.instructor == "" ? "" : "/") + "\(lecture.credit)학점"
    }

    func setUp() {
        self.backgroundColor = UIColor.clear
        self.selectionStyle = .none
        titleLabel.trailingBuffer = 10.0
        tagLabel.trailingBuffer = 10.0
        titleLabel.animationDelay = 0.3
        tagLabel.animationDelay = 0.3
        addButton.buttonPressAction = { [ weak self] in
            guard let self = self else { return }
            self.timetableManager.setTemporaryLecture(nil)
            self.tableView.deselectRow(at: self.tableView.indexPath(for: self)!, animated: true)
            let index = self.indexInTimetable()
            if index >= 0{
                // TODO: move this buttonPressAction to controller
                let _ = self.timetableManager.deleteLectureAtIndex(index).subscribe()
            } else {
                // TODO: move this buttonPressAction to controller
                let _ = self.timetableManager.addLecture(self.lecture!.id!).subscribe()
            }
            self.setAddButton()
        }
    }

    func setAddButton() {
        let index = indexInTimetable()
        if index < 0 {
            addButtonLabel.text = "+ 추가하기"
        } else {
            addButtonLabel.text = "제거하기"
        }

    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setUp();
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected {
            self.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.3)
            setAddButton()
            addButton.isHidden = false
            tagLabel.text = lecture!.remark == "" ? lecture!.tagDescription : lecture!.remark
        } else {
            self.backgroundColor = UIColor.clear
            addButton.isHidden = true
            tagLabel.text = lecture?.tagDescription
        }
        titleLabel.labelize = !selected
        tagLabel.labelize = !selected
        // 800, 790 is because of priority in content wrapping
        constraintForHidden.priority = !selected ? UILayoutPriority(800):UILayoutPriority(790)
        constraintForShown.priority = selected ? UILayoutPriority(800):UILayoutPriority(790)
        setDescLabel()
        // Configure the view for the selected state
    }


}
