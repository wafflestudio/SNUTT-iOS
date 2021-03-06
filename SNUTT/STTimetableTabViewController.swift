//
//  STTimetableTabViewController.swift
//  SNUTT
//
//  Created by Rajin on 2016. 1. 7..
//  Copyright © 2016년 WaffleStudio. All rights reserved.
//

import UIKit

class STTimetableTabViewController: UIViewController {
    
    @IBOutlet weak var timetableView: STTimetableCollectionView!
    var lectureListController : STMyLectureListController!
    
    enum State {
    case timetable
    case lectureList
    }
    
    var state : State = .timetable
    var isInAnimation : Bool = false
    
    @IBAction func captureTimeTable(_ sender: UIBarButtonItem) {
        showCaptureAlert()
    }
    
    @IBOutlet weak var containerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add tap recognizer to title in NavigationBar
        let titleView = UILabel()
        titleView.text = STTimetableManager.sharedInstance.currentTimetable?.title ?? ""
        titleView.font = UIFont(name: "HelveticaNeue-Medium", size: 17)
        let width = titleView.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)).width
        titleView.frame = CGRect(origin:CGPoint.zero, size:CGSize(width: width, height: 500))
        titleView.textAlignment = .center
        self.navigationItem.titleView = titleView
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(STTimetableTabViewController.titleWasTapped))
        titleView.isUserInteractionEnabled = true
        titleView.addGestureRecognizer(recognizer)
        
        self.navigationItem.leftBarButtonItem!.target = self
        self.navigationItem.leftBarButtonItem!.action = #selector(self.switchView)
        
        lectureListController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "MyLectureListController") as! STMyLectureListController
        lectureListController.timetableTabViewController = self
        lectureListController.view.frame = self.containerView.frame
        self.containerView.addSubview(lectureListController.view)
        lectureListController.view.isHidden = true

        timetableView.timetable = STTimetableManager.sharedInstance.currentTimetable
        settingChanged()

        timetableView.cellLongClicked = self.cellLongClicked
        timetableView.cellTapped = self.cellTapped

        let _ = STColorManager.sharedInstance

        STEventCenter.sharedInstance.addObserver(self, selector: #selector(STTimetableTabViewController.reloadData), event: STEvent.CurrentTimetableChanged, object: nil)
        STEventCenter.sharedInstance.addObserver(self, selector: #selector(STTimetableTabViewController.reloadData), event: STEvent.CurrentTimetableSwitched, object: nil)
        STEventCenter.sharedInstance.addObserver(self, selector: #selector(STTimetableTabViewController.settingChanged), event: STEvent.SettingChanged, object: nil)
        
        reloadData()
    }

    deinit {
        STEventCenter.sharedInstance.removeObserver(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func reloadData() {
        let titleView = (self.navigationItem.titleView as! UILabel)
        titleView.text = STTimetableManager.sharedInstance.currentTimetable?.title ?? ""
        titleView.sizeToFit();
        
        timetableView.timetable = STTimetableManager.sharedInstance.currentTimetable
        timetableView.reloadTimetable()
    }
    
    @objc func settingChanged() {
        if STDefaults[.autoFit] {
            timetableView.shouldAutofit = true
        } else {
            timetableView.shouldAutofit = false
            let dayRange = STDefaults[.dayRange]
            var columnHidden : [Bool] = []
            for i in 0..<6 {
                if dayRange[0] <= i && i <= dayRange[1] {
                    columnHidden.append(false)
                } else {
                    columnHidden.append(true)
                }
            }
            timetableView.columnHidden = columnHidden
            timetableView.rowStart = Int(STDefaults[.timeRange][0])
            timetableView.rowEnd = Int(STDefaults[.timeRange][1])
        }
        timetableView.reloadTimetable()
    }
    
    @objc func switchView() {

        if (isInAnimation) {
            return
        }
        isInAnimation = true
        var oldView, newView : UIView!
        switch state {
        case .timetable:
            oldView = timetableView
            newView = lectureListController.view
        case .lectureList:
            oldView = lectureListController.view
            newView = timetableView
        }

        UIView.animate(withDuration: 0.65, animations: {
            switch self.state {
            case .lectureList:
                self.navigationItem.leftBarButtonItem!.image = #imageLiteral(resourceName: "topbarListview")
            case .timetable:
                self.navigationItem.leftBarButtonItem!.image = #imageLiteral(resourceName: "group2Copy")
            }
        })

        UIView.transition(with: containerView, duration: 0.65, options: .transitionFlipFromRight, animations: {
                oldView.isHidden = true
                newView.isHidden = false
            }, completion: { finished in
                self.state = (self.state == .timetable) ? .lectureList : .timetable
                self.isInAnimation = false
        })
    }
    
    @objc func titleWasTapped() {
        guard let currentTimetable = STTimetableManager.sharedInstance.currentTimetable else {
            return
        }
        guard let timetableId = currentTimetable.id else {
            return
        }
        
        STAlertView.showAlert(title: "시간표 이름 변경", message: "새로운 시간표 이름을 입력해주세요", configAlert: { alert in
            alert.addTextField(configurationHandler: { textfield in
                textfield.placeholder = "새로운 시간표 이름"
            })
            alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "이름 변경", style: .default, handler: { _ in
                if let timetableName = alert.textFields?.first?.text {
                    STNetworking.updateTimetable(timetableId, title: timetableName, done: {
                        STTimetableManager.sharedInstance.currentTimetable?.title = timetableName
                        STEventCenter.sharedInstance.postNotification(event: .CurrentTimetableChanged, object: nil)
                    })
                }
            }))
        })
    }

    func cellTapped(_ cell: STCourseCellCollectionViewCell) {
        let detailController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "LectureDetailTableViewController") as! STLectureDetailTableViewController
        detailController.lecture = cell.lecture
        self.navigationController?.pushViewController(detailController, animated: true)

    }

    func cellLongClicked (_ cell : STCourseCellCollectionViewCell) {
        let oldColorIndex = cell.lecture.colorIndex;
        guard let collectionView = timetableView else {
            return
        }
        guard let indexPath = timetableView.indexPath(for: cell) else {
            return
        }
        let num = collectionView.numberOfItems(inSection: indexPath.section)
        let cellList : [STCourseCellCollectionViewCell?] = (0..<num).map { i in
            let tmpIndexPath = IndexPath(row: i, section: indexPath.section)
            return collectionView.cellForItem(at: tmpIndexPath) as? STCourseCellCollectionViewCell
        }
        var oldLecture = cell.lecture!
        STColorActionSheetPicker.showWithColor(oldColorIndex ?? 0, doneBlock: { selectedColorIndex in
            var newLecture = cell.lecture
            newLecture?.colorIndex = selectedColorIndex
            newLecture?.color = nil
            STTimetableManager.sharedInstance.updateLecture(
                oldLecture, newLecture: newLecture!, done: {  return }, failure: {
                    cellList.forEach { cell in
                        cell?.setColorByLecture(lecture: oldLecture)
                    }
            })
            }, cancelBlock: {
                cellList.forEach { cell in
                    cell?.setColorByLecture(lecture: oldLecture)
                }
            }, selectedBlock: { colorIndex in
                cellList.forEach { cell in
                    let color = STColorManager.sharedInstance.colorList.colorList[colorIndex-1]
                    cell?.setColor(color: color)
                }
            }, origin: self)
    }
}

extension STTimetableTabViewController {
    func showCaptureAlert() {
        let actions = [UIAlertAction(title: "취소", style: .cancel, handler: nil),
                       UIAlertAction(title: "확인", style: .default, handler: { action in
                        self.captureTimetableView(of: self.view)
        })]
        
        STAlertView.showAlert(title: "시간표를 이미지로 저장하시겠습니까?", message: "", actions: actions)
    }
    
    func captureTimetableView(of view: UIView) {
        UIGraphicsBeginImageContextWithOptions(
            CGSize(
                width: view.bounds.width,
                height: view.bounds.height
            ),
            false,
            2
        )

        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        let screenshot = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        UIView.animate(withDuration: 0.3, animations: { self.view.alpha = 0.4 }) {_ in
            self.view.alpha = 1
        }
        
        UIImageWriteToSavedPhotosAlbum (
            screenshot,
            self,
            #selector(imageSaved),
            nil
        )
    }
            
    @objc func imageSaved(_ image: UIImage, error: Error?, context: UnsafeMutableRawPointer) {
        if let error = error {
            print(error.localizedDescription)
            return
        }
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSAttributedStringKey(_ input: NSAttributedString.Key) -> String {
	return input.rawValue
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
	guard let input = input else { return nil }
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}
