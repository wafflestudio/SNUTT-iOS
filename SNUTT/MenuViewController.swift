//
//  MenuViewController.swift
//  SNUTT
//
//  Created by Jinsup Keum on 2021/07/03.
//  Copyright © 2021 WaffleStudio. All rights reserved.
//

import Foundation

class MenuViewController: UIViewController {
    
    struct Section {
        var timetableList : [STTimetable]
        var courseBook : STCourseBook
        var quarter: STQuarter
    }
    
    var timetableList : [STTimetable] = []
    var sectionList : [Section] = []
    
    let currentTimetable = {
        return STTimetableManager.sharedInstance.currentTimetable
    }
    
    var currentQurterTimetableList: [STTimetable] {
        return currentSection[0].timetableList
    }
    
    var currentSection: [Section] {
        return sectionList.filter({ section in
            section.quarter == currentTimetable()?.quarter
        })
    }
    
    @IBOutlet weak var timetableListTableView: UITableView!
    
    
    @IBAction func dismiss(_ sender: UIButton) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.frame.size.width = UIScreen.main.bounds.size.width - 72
        
        timetableListTableView.delegate = self
        timetableListTableView.dataSource = self
        registerCellXib()
        registerHeaderView()
        
        STNetworking.getTimetableList({ list in
            self.timetableList = list
            self.reloadList()
        }, failure: {
            // TODO: No network status handling
            self.dismiss(animated: true, completion: nil)
        })
        
        STEventCenter.sharedInstance.addObserver(self, selector: #selector(self.reloadList), event: STEvent.CourseBookUpdated, object: nil)
        STEventCenter.sharedInstance.addObserver(self, selector: #selector(self.reloadList), event: STEvent.CurrentTimetableChanged, object: nil)
        STEventCenter.sharedInstance.addObserver(self, selector: #selector(self.reloadList), event: STEvent.CurrentTimetableSwitched, object: nil)
        reloadList()
    }
    
    var semesterList: [STQuarter]  {
        return self.sectionList.map({section in
            return section.courseBook.quarter
        })
    }
    
    @objc func reloadList() {
        
        self.updateSectionedList()
        timetableListTableView.reloadData()
    }
    
    func updateSectionedList() {
        let courseBookList = STCourseBookList.sharedInstance.courseBookList
        sectionList = courseBookList.map({ courseBook in
            return Section.init(timetableList:
                                    timetableList.filter({ timetable in
                                        timetable.quarter == courseBook.quarter
                                    }), courseBook: courseBook, quarter: courseBook.quarter)
        })
    }
}

extension MenuViewController: UITableViewDelegate, UITableViewDataSource, MenuTableViewHeaderViewDelegate {
    var cellLength: Int {
        return currentSection[0].timetableList.count + 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellLength
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = timetableListTableView.dequeueReusableCell(withIdentifier: "menuTableViewCell", for: indexPath)
        // 요거 고쳐야댐
        if cellLength > 1 {
        
        if let customCell = cell as? MenuTableViewCell {
            customCell.delegate = self
            if indexPath.row == cellLength - 1 && cellLength > 1{
                customCell.setLabel(text: "+ 시간표 추가하기")
                customCell.setCreateNewCellStyle()
            } else {
                let timatable = currentQurterTimetableList[indexPath.row]
                customCell.setLabel(text: timatable.title)
                customCell.setCredit(credit: timatable.totalCredit)
                
                if !(currentQurterTimetableList[indexPath.row] == currentTimetable()) {
                    customCell.hideCheckIcon()
                }
            }
        }
            
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let view = timetableListTableView.dequeueReusableHeaderFooterView(withIdentifier: "MenuTableViewHeaderView") as? MenuTableViewHeaderView, let currentTT = currentTimetable()
        else { return nil }
        view.delegate = self
        view.setHeaderLabel(text: currentTT.quarter.longString())
        
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 32
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == cellLength - 1 {
            showCreateTextfield()
        }
    }
    
    private func registerCellXib() {
        let nib = UINib(nibName: "MenuTableViewCell", bundle: nil)
        timetableListTableView.register(nib, forCellReuseIdentifier: "menuTableViewCell")
    }
    
    private func registerHeaderView() {
        let nib = UINib(nibName: "MenuTableViewHeaderView", bundle: nil)
        timetableListTableView.register(nib, forHeaderFooterViewReuseIdentifier: "MenuTableViewHeaderView")
    }
    
    private func showCreateTextfield() {
        let alert = UIAlertController(title: "시간표 이름", message: nil, preferredStyle: .alert)
        alert.addTextField { textfield in
            textfield.minimumFontSize = 21
            textfield.placeholder = "멋진 시간표"
        }
        
        let create = UIAlertAction(title: "만들기", style: .default) { action in
            guard let text = alert.textFields?[0].text else { return }
            
            self.addTimetable(text, courseBook: self.currentSection[0].courseBook)
        }
        
        let cancel = UIAlertAction(title: "취소", style: .cancel)
        
        alert.addAction(create)
        alert.addAction(cancel)
        present(alert, animated: true)
    }
}

extension MenuViewController: TimetablePickerViewControllerDelegate {
    func presentSemesterPickView(_: MenuTableViewHeaderView) {
        let pickerViewController = TimetablePickerViewController(nibName: "TimetablePickerViewController", bundle: nil)
        pickerViewController.setSemesterList(list: semesterList)
        
        if let currentQuarter = currentTimetable()?.quarter {
            pickerViewController.setSelectedSemester(index: semesterList.index(of: currentQuarter))
        } else {
            pickerViewController.setSelectedSemester(index: 0)
        }
        
        pickerViewController.delegate = self
        
        present(pickerViewController, animated: true)
    }
    
    func changeSemester(_ controller: TimetablePickerViewController, index: Int) {
        let section = sectionList[index]
        if section.timetableList.count == 0 {
            // create a new timetable and move to that timetable
            addTimetable("새로운 시간표", courseBook: section.courseBook)
            return
        }
        
        guard let id = sectionList.get(index)?.timetableList.get(0)?.id else {
            return
        }
        
        STNetworking.getTimetable(id, done: { timetable in
            if (timetable == nil) {
                STAlertView.showAlert(title: "시간표 로딩 실패", message: "선택한 시간표가 서버에 존재하지 않습니다.")
            }
            STTimetableManager.sharedInstance.currentTimetable = timetable
            self.navigationController?.popViewController(animated: true)
        }, failure: { _ in
            
        })
    }
    
    private func addTimetable(_ title : String, courseBook : STCourseBook) {
        let newTimetable = STTimetable(courseBook: courseBook, title: title)
        STNetworking.createTimetable(title, courseBook: courseBook, done: { list in
            
            self.timetableList.append(newTimetable)
            self.timetableList = list
            self.reloadList()
        }, failure: {
            // TODO: 응답에 따른 에러 핸들링
            let alert = UIAlertController(title: "시간표 만들기 실패", message: "중복된 시간표 이름입니다", preferredStyle: .alert)
            let ok = UIAlertAction(title: "확인", style: .cancel)
            alert.addAction(ok)
            self.present(alert, animated: true)
            
        })
    }
}

extension MenuViewController: MenuTableViewCellDelegate {
    func showSettingSheet(_ cell: MenuTableViewCell) {
        let sheetAlert = UIAlertController(title: "곧 만들게영", message: "", preferredStyle: .actionSheet)
        let cancel = UIAlertAction(title: "", style: .cancel)
        sheetAlert.addAction(cancel)
        
//        let settingController = SettingViewController(nibName: "SettingViewController", bundle: nil)
        
//        sheetAlert.addChild(settingController)
//        sheetAlert.view.addSubview(settingController.view)
        
//        sheetAlert.addAction(cancel, handler: {
//                    (alertAction: UIAlertAction!) in
//            sheetAlert.dismiss(animated: true, completion: nil)
//                })
        present(sheetAlert, animated: true)
    }
}
