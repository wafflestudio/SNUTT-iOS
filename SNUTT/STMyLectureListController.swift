//
//  STMyLectureListController.swift
//  SNUTT
//
//  Created by Rajin on 2016. 1. 8..
//  Copyright © 2016년 WaffleStudio. All rights reserved.
//

import UIKit
import DZNEmptyDataSet
import RxSwift

class STMyLectureListController: UITableViewController, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    let disposeBag = DisposeBag()
    let timetableManager = AppContainer.resolver.resolve(STTimetableManager.self)!

    weak var timetableTabViewController : STTimetableTabViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.emptyDataSetSource = self;
        self.tableView.emptyDataSetDelegate = self;
        
        self.tableView.register(UINib(nibName: "STLectureTableViewCell", bundle: nil), forCellReuseIdentifier: "LectureCell")
        self.tableView.register(UINib(nibName: "STAddLectureButtonCell", bundle: nil), forCellReuseIdentifier: "AddButtonCell")
        self.tableView.separatorStyle = .none
        self.tableView.rowHeight = 74.0

        timetableManager.rx.currentTimetable.subscribe(onNext: {[weak self] _ in
            self?.reloadData()
        })

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func reloadData() {
        self.tableView.reloadData()
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let cnt = timetableManager.currentTimetable?.lectureList.count {
            return cnt == 0 ? 0 : cnt + 1
        }
        return 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == timetableManager.currentTimetable?.lectureList.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddButtonCell", for: indexPath) as! STAddLectureButtonCell
            cell.titleLabel.text = "직접 강좌 추가하기"
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "LectureCell", for: indexPath) as! STLectureTableViewCell
            cell.lecture = timetableManager.currentTimetable?.lectureList[indexPath.row]
            return cell
        }
    }
    

    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.row == timetableManager.currentTimetable?.lectureList.count {
            return false
        }
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            timetableManager.deleteLectureAtIndex(indexPath.row)
                .subscribe()
                .disposed(by: disposeBag)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == timetableManager.currentTimetable?.lectureList.count {
            self.performSegue(withIdentifier: "AddCustomLecture", sender: self)
        } else {
            let detailController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "LectureDetailTableViewController") as! STLectureDetailTableViewController
            detailController.lecture = timetableManager.currentTimetable?.lectureList[indexPath.row]
            timetableTabViewController?.navigationController?.pushViewController(detailController, animated: true)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == timetableManager.currentTimetable?.lectureList.count {
            return 40.0
        }
        return 106.0
    }
    
    //MARK: DNZEmptyDataSet
    
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return #imageLiteral(resourceName: "tabTimetableOn")
    }

    func imageTintColor(forEmptyDataSet scrollView: UIScrollView!) -> UIColor! {
        return UIColor(white: 0.8, alpha: 1.0)
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let text = "시간표에 강좌가 없습니다."
        let attributes: [NSAttributedString.Key : AnyObject] = [
            NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 18.0)
        ]
        return NSAttributedString(string: text, attributes: attributes)
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let text = "강좌를 찾아서 넣을수도 있지만, 직접 만들수도 있습니다.".breakOnlyAtNewLineAndSpace
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineBreakMode = .byWordWrapping
        paragraph.alignment = .center
        let attributes: [NSAttributedString.Key: AnyObject] = [
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14.0),
            NSAttributedString.Key.foregroundColor : UIColor.lightGray,
            NSAttributedString.Key.paragraphStyle : paragraph
        ]
        return NSAttributedString(string: text, attributes: attributes)
    }
    
    func buttonTitle(forEmptyDataSet scrollView: UIScrollView!, for state: UIControl.State) -> NSAttributedString! {
        let text = "직접 만들기"
        let attributes: [NSAttributedString.Key : AnyObject] = [
            NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 17.0)
        ]
        return NSAttributedString(string: text, attributes: attributes)
    }
    
    func emptyDataSetDidTapButton(_ scrollView: UIScrollView!) {
        self.performSegue(withIdentifier: "AddCustomLecture", sender: self)
    }
    
    
    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

}
