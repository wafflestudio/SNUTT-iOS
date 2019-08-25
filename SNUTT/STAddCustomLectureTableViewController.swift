//
//  STAddCustomLectureTableViewController.swift
//  SNUTT
//
//  Created by Rajin on 2016. 2. 23..
//  Copyright © 2016년 WaffleStudio. All rights reserved.
//

import UIKit
import RxSwift

class STAddCustomLectureTableViewController: STSingleLectureTableViewController {
    let colorManager = AppContainer.resolver.resolve(STColorManager.self)!
    override func viewDidLoad() {
        super.viewDidLoad()

        self.custom = true
        currentLecture.color = nil
        if let timetable = timetableManager.currentTimetable {
            var colorList = colorManager.colorList.colorList
            var indexList = (0..<colorList.count).sorted()
            for lecture in timetable.lectureList {
                indexList = indexList.filter({colorList[$0] != lecture.color})
            }
            currentLecture.colorIndex = (indexList.first ?? 0) + 1
        } else {
            currentLecture.colorIndex = 1
        }

        self.sectionForSingleClass = 2
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func cellTypeAtIndexPath(_ indexPath : IndexPath) -> CellType {
        switch (indexPath.section, indexPath.row) {
        case (0,0): return .editLecture(attribute: .title)
        case (0,1): return .editLecture(attribute: .instructor)
        case (0,2): return .color
        case (0,3): return .editLecture(attribute: .credit)

        case (1,0): return .padding
        case (1,1): return .remark
        case (1,2): return .padding

        case (2, 0): return .singleClassTitle
        case (2, currentLecture.classList.count + 1): return .addButton(section: 2)
        case (2, _): return .singleClass

        default: return .padding // Never Reach
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 4
        case 1: return 3
        case 2: return currentLecture.classList.count + 2
        default: return 0 // Never Reached
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath) as! STLectureDetailTableViewCell
        cell.setEditable(true)
        let leftAlignedCell = cell as? STLeftAlignedTextFieldCell
        switch cellTypeAtIndexPath(indexPath) {
        case let .editLecture(attribute):
            if (attribute == .instructor) {
                leftAlignedCell?.textField.placeholder = "예) 홍길동"
            } else if (attribute == .title) {
                leftAlignedCell?.textField.placeholder = "예) 기초 영어"
            }
            break
        default: break
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if case .color = cellTypeAtIndexPath(indexPath){
            tableView.deselectRow(at: indexPath, animated: true)
            triggerColorPicker()
        } else if case .addButton = cellTypeAtIndexPath(indexPath) {
            tableView.deselectRow(at: indexPath, animated: true)
            (self.tableView.cellForRow(at: indexPath) as! STSingleLectureButtonCell).buttonAction?()
        }
    }
    
    @IBAction func cancelButtonClicked(_ sender: UIBarButtonItem) {
        self.view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveButtonClicked(_ sender: UIBarButtonItem) {
        self.view.endEditing(true)
        let loadingView = STAlertView.showLoading(title: "저장중...")
        timetableManager.addCustomLecture(currentLecture)
            .subscribe(onCompleted: { [weak self] in
                loadingView.dismiss(animated: true, completion: { [weak self] in
                    self?.dismiss(animated: true)
                })
                }, onError: { err in
                    loadingView.dismiss(animated: true)
            }).disposed(by: disposeBag)
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 1 {
            if indexPath.row < currentLecture.classList.count {
                return true
            }
        }
        return false
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            currentLecture.classList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
