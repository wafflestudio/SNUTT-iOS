//
//  STLectureDetailTableViewController.swift
//  SNUTT
//
//  Created by 김진형 on 2015. 7. 3..
//  Copyright (c) 2015년 WaffleStudio. All rights reserved.
//

import UIKit
import ChameleonFramework
import RxSwift

class STLectureDetailTableViewController: STSingleLectureTableViewController {
    var lecture : STLecture!
    var editable : Bool = false
    
    var editBarButton : UIBarButtonItem!
    var saveBarButton : UIBarButtonItem!
    var cancelBarButton : UIBarButtonItem!
    
    override func viewDidLoad() {
        if lecture.lectureNumber == nil && lecture.courseNumber == nil {
            self.custom = true
        } else {
            self.custom = false
        }
        super.viewDidLoad()
        
        self.currentLecture = lecture
        self.sectionForSingleClass = 2
        
        editBarButton = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(STLectureDetailTableViewController.editBarButtonClicked))
        saveBarButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(STLectureDetailTableViewController.saveBarButtonClicked))
        cancelBarButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(STLectureDetailTableViewController.cancelBarButtonClicked))
        
        self.navigationItem.rightBarButtonItem = editBarButton
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if case .button = cellTypeAtIndexPath(indexPath).simpleCellViewType {
            tableView.deselectRow(at: indexPath, animated: true)
            (self.tableView.cellForRow(at: indexPath) as! STSingleLectureButtonCell).buttonAction?()
        } else if case .color = cellTypeAtIndexPath(indexPath) {
            if editable {
                tableView.deselectRow(at: indexPath, animated: true)
                triggerColorPicker()
            } else {
                tableView.deselectRow(at: indexPath, animated: false)
            }
        } else {
            tableView.deselectRow(at: indexPath, animated: false)
        }
    }
    
    override func cellTypeAtIndexPath(_ indexPath : IndexPath) -> CellType {
        switch (indexPath.section, indexPath.row) {
        case (0, 0): return .padding
        case (0, 1): return .editLecture(attribute: .title)
        case (0, 2): return .editLecture(attribute: .instructor)
        case (0, 3): return .color
        case (0, 4): return custom ? .editLecture(attribute: .credit) : .padding
        case (0, 5): return .padding

        case (1, _):
            if custom {
                switch indexPath.row {
                case 0: return .padding
                case 1: return .remark
                case 2: return .padding
                default: return .padding
                }
            } else {
                switch indexPath.row {
                case 0: return .padding
                case 1: return .editLecture(attribute: .department)
                case 2: return .editLecture(attribute: .academicYear)
                case 3: return .editLecture(attribute: .credit)
                case 4: return .editLecture(attribute: .classification)
                case 5: return .editLecture(attribute: .category)
                case 6: return .editLecture(attribute: .courseNum)
                case 7: return .editLecture(attribute: .lectureNum)
                case 8: return .remark
                case 9: return .padding
                default: return .padding
                }
            }
        case (2, 0):
            return .singleClassTitle

        case (2, currentLecture.classList.count + 1):
            return editable ? .addButton(section: 2) : .padding
            
        case (2, _): return .singleClass
            
        case (3, 0):
            if custom {
                return .deleteButton
            } else if editable {
                return .resetButton
            } else {
                return .syllabusButton
            }
        case (4, 0):
            return .deleteButton
        default: return .padding // Never Reach
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if custom {
            return editable ? 3 : 4
        } else {
            return editable ? 4 : 5
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 3 && !custom && !editable {
            return CGFloat.leastNormalMagnitude
        }
        return super.tableView(tableView, heightForFooterInSection: section)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if custom {
            switch section {
            case 0: return 6
            case 1: return 3
            case 2: return currentLecture.classList.count + 2
            case 3: return editable ? 0 : 1
            default: return 0 // Never Reached
            }
        } else {
            switch section {
            case 0: return 5
            case 1: return 10
            case 2: return currentLecture.classList.count + 2
            case 3: return 1
            case 4: return 1
            default: return 0
            }
        }

    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath) as! STLectureDetailTableViewCell
        cell.setEditable(editable)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            currentLecture.classList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    @objc func editBarButtonClicked() {
        editable = true
        reloadDataWithAnimation()
        self.navigationItem.setRightBarButton(saveBarButton, animated: true)
        self.navigationItem.setLeftBarButton(cancelBarButton, animated: true)
    }
    
    @objc func saveBarButtonClicked() {
        dismissKeyboard()
        let loadingView = STAlertView.showLoading(title: "저장 중")
        let oldLecture = lecture!
        timetableManager.updateLecture(oldLecture, newLecture: currentLecture)
            .subscribe(onCompleted: { [weak self] in
                guard let self = self else { return }
                self.editable = false
                self.reloadDataWithAnimation()
                self.navigationItem.setRightBarButton(self.editBarButton, animated: true)
                self.navigationItem.setLeftBarButton(nil, animated: true)
                self.lecture = self.currentLecture
                loadingView.dismiss(animated: true)
                }, onError: { [weak self] err in
                    self?.errorHandler.apiOnError(err)
                    loadingView.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
    }
    
    @objc func cancelBarButtonClicked() {
        editable = false
        dismissKeyboard()
        currentLecture = lecture
        reloadDataWithAnimation()
        self.navigationItem.setRightBarButton(editBarButton, animated: true)
        self.navigationItem.setLeftBarButton(nil, animated: true)
    }
    
    func reloadDataWithAnimation() {
        UIView.transition(with: tableView, duration:0.35, options:.transitionCrossDissolve,
                                  animations: { self.tableView.reloadData() }, completion: nil);
    }
    
    override func resetButtonClicked() {
        guard let currentLectureId = self.currentLecture.id else {
            return
        }
        timetableManager.resetLecture(currentLectureId)
            .subscribe(onCompleted: {
                let lectureList = self.timetableManager.currentTimetable!.lectureList
                if let index = lectureList.index(where: { lecture in lecture.id == self.currentLecture.id}) {
                    self.currentLecture = lectureList[index]
                    self.lecture = lectureList[index]
                    self.navigationItem.setRightBarButton(self.editBarButton, animated: true)
                    self.navigationItem.setLeftBarButton(nil, animated: true)
                    UIView.transition(with: self.tableView, duration:0.35, options:.transitionCrossDissolve,
                                      animations: {
                                        self.editable = false
                                        self.tableView.reloadData()
                    }, completion: nil);
                }
            }).disposed(by: disposeBag)
    }
    // MARK: - Table view data source
    

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
