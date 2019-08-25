//
//  STTimetableListController.swift
//  SNUTT
//
//  Created by Rajin on 2016. 1. 7..
//  Copyright © 2016년 WaffleStudio. All rights reserved.
//

import UIKit
import Alamofire
import RxSwift

class STTimetableListController: UITableViewController {

    let courseBookListManager = AppContainer.resolver.resolve(STCourseBookListManager.self)!
    let timetableManager = AppContainer.resolver.resolve(STTimetableManager.self)!
    let networkProvider = AppContainer.resolver.resolve(STNetworkProvider.self)!
    let errorHandler = AppContainer.resolver.resolve(STErrorHandler.self)!
    let disposeBag = DisposeBag()

    struct Section {
        var timetableList : [STTimetable]
        var courseBook : STCourseBook
    }

    var timetableList : [STTimetable] = []
    var sectionList : [Section] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        networkProvider.rx.request(STTarget.GetTimetableList())
            .subscribe(onSuccess: { [weak self] list in
                self?.timetableList = list
                self?.reloadList()
                }, onError: { [weak self] err in
                    self?.errorHandler.apiOnError(err)
                    self?.dismiss(animated: true, completion: nil)
            }).disposed(by: disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        STEventCenter.sharedInstance.addObserver(self, selector: #selector(self.reloadList), event: STEvent.CourseBookUpdated, object: nil)
        reloadList()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        STEventCenter.sharedInstance.removeObserver(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addTimetable(_ title : String, courseBook : STCourseBook) {
        let newTimetable = STTimetable(courseBook: courseBook, title: title)
        timetableList.append(newTimetable)
        reloadList()
        let quarter = courseBook.quarter
        networkProvider.rx.request(STTarget.CreateTimetable(params: .init(title: title, year: quarter.year, semester: quarter.semester)))
            .subscribe(onSuccess: { [weak self] list in
                self?.timetableList = list
                self?.reloadList()
                }, onError: { [weak self] error in
                    guard let self = self else { return }
                    self.errorHandler.apiOnError(error)
                    let index = self.timetableList.index(of: newTimetable)
                    self.timetableList.remove(at: index!)
                    self.reloadList()
            })
            .disposed(by: disposeBag)
    }
    
    @objc func reloadList() {
        self.updateSectionedList()
        self.tableView.reloadData()
    }
    
    func updateSectionedList() {
        let courseBookList = courseBookListManager.courseBookList
        sectionList = courseBookList.map({ courseBook in
            return Section.init(timetableList:
                timetableList.filter({ timetable in
                    timetable.quarter == courseBook.quarter
                }), courseBook: courseBook)
        })
    }

    func getTimetable(from indexPath: IndexPath) -> STTimetable? {
        return sectionList.get(indexPath.section)?.timetableList.get(indexPath.row)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return sectionList.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return max(sectionList[section].timetableList.count, 1)
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "STTimetableListCell", for: indexPath)
        if let timetable = getTimetable(from: indexPath) {
            cell.textLabel?.text = timetable.title
            if timetableManager.currentTimetable?.id == timetable.id {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
            if timetable.isLoaded {
                cell.textLabel?.textColor = UIColor.black
            } else {
                cell.textLabel?.textColor = UIColor.gray
            }
        } else {
            if sectionList[indexPath.section].timetableList.count == 0 {
                cell.textLabel?.text = "+ 새로운 시간표"
                cell.accessoryType = .none
            }
            cell.textLabel?.textColor = UIColor.gray
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionList[section].courseBook.quarter.longString()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = sectionList[indexPath.section]
        if section.timetableList.count == 0 {
            // create a new timetable and move to that timetable
            addTimetable("시간표 1", courseBook: section.courseBook)
            return
        }
        guard let id = getTimetable(from: indexPath)?.id else {
            return
        }
        timetableManager.getTimetable(id: id)
            .subscribe(onCompleted: { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            }).disposed(by: disposeBag)
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        guard let timetable = getTimetable(from: indexPath) else {
            return false
        }
        if timetable.isLoaded {
            if timetableManager.currentTimetable?.id == timetable.id  {
                return false
            }
            return true
        } else {
            return false
        }
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            guard let timetable = getTimetable(from: indexPath), let id = timetable.id else {
                return
            }
            networkProvider.rx.request(STTarget.DeleteTimetable(id: id))
                .subscribe(onSuccess: { _ in
                    guard let index = self.timetableList.index(of: timetable) else {
                        return
                    }
                    let section = self.sectionList.filter({ section in section.timetableList.contains(timetable)})
                    self.timetableList.remove(at: index)
                    self.updateSectionedList()
                    if section.count > 0 && section.first!.timetableList.count > 1 {
                        self.tableView.deleteRows(at: [indexPath], with: .fade)
                    } else {
                        self.tableView.reloadRows(at: [indexPath], with: .fade)
                    }
                }, onError: errorHandler.apiOnError)
                .disposed(by: disposeBag)
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "STTimetableAddController" {
            ((segue.destination as! UINavigationController).topViewController as! STTimetableAddController).timetableListController = self
        }
    }
    

}
