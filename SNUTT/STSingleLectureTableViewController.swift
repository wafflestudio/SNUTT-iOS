//
//  STSingleLectureTableViewController.swift
//  SNUTT
//
//  Created by Rajin on 2016. 2. 23..
//  Copyright © 2016년 WaffleStudio. All rights reserved.
//

import UIKit
import ChameleonFramework
import SafariServices
import RxSwift

class STSingleLectureTableViewController: UITableViewController {
    // TODO: Seriously needs refactoring
    let timetableManager = AppContainer.resolver.resolve(STTimetableManager.self)!
    let errorHandler = AppContainer.resolver.resolve(STErrorHandler.self)!
    let networkProvider = AppContainer.resolver.resolve(STNetworkProvider.self)!

    var custom : Bool = false
    var currentLecture : STLecture = STLecture()
    var sectionForSingleClass : Int = 4
    let disposeBag = DisposeBag()

    enum LectureAttributes {
        case title
        case instructor
        case credit
        case department
        case academicYear
        case classification
        case category
        case courseNum
        case lectureNum

        var titleName : String {
            switch self {
            case .title: return "lecture_title".localizedString()
            case .instructor: return "instructor".localizedString()
            case .credit: return "credit".localizedString()
            case .department: return "department".localizedString()
            case .academicYear: return "academic_year".localizedString()
            case .classification: return "classification".localizedString()
            case .category: return "category".localizedString()
            case .courseNum: return "course_number".localizedString()
            case .lectureNum: return "lecture_number".localizedString()
            }
        }
    }



    func doneBlockFor(attribute : LectureAttributes) -> (String)->() {
        return { (str: String) -> Void in
            switch attribute {
            case .title: self.currentLecture.title = str
            case .instructor: self.currentLecture.instructor = str
            case .credit:
                self.currentLecture.credit = Int(str) ?? 0
                if self.currentLecture.credit < 0 {
                    self.currentLecture.credit = 0
                }
            case .department: self.currentLecture.department = str
            case .academicYear: self.currentLecture.academicYear = str
            case .classification: self.currentLecture.classification = str
            case .category: self.currentLecture.category = str
            case .courseNum: return
            case .lectureNum: return
            }
        }
    }

    func initialValueFor(attribute: LectureAttributes) -> String {
        switch attribute {
        case .title: return currentLecture.title
        case .instructor: return currentLecture.instructor
        case .credit: return String(currentLecture.credit)
        case .department: return currentLecture.department ?? ""
        case .academicYear: return currentLecture.academicYear ?? ""
        case .classification: return currentLecture.classification ?? ""
        case .category: return currentLecture.category ?? ""
        case .courseNum: return currentLecture.courseNumber ?? ""
        case .lectureNum: return currentLecture.lectureNumber ?? ""
        }
    }

    enum CellViewType {
        case leftAligned(title: String, doneBlock: (String)->(), initialValue: String)
        case colorPick
        case padding
        case singleClass
        case leftAlignedLabel(string : String)
        case textView(title: String)
        case button(title: String, color : UIColor, onClick: ()->())
        
        var identifier : String {
            switch self {
            case .leftAligned: return "LeftAlignedCell"
            case .leftAlignedLabel: return "LeftAlignedLabelCell"
            case .colorPick: return "ColorPickCell"
            case .padding: return "PaddingCell"
            case .singleClass: return "SingleClassCell"
            case .textView: return "TextViewCell"
            case .button: return "ButtonCell"
            }
        }

    }
    
    enum CellType {
        case editLecture(attribute: LectureAttributes)
        case color
        case remark
        case singleClass
        case singleClassTitle
        case padding
        case addButton(section : Int)
        case resetButton
        case syllabusButton
        case deleteButton

        var simpleCellViewType : CellViewType {
            switch self {
            case let .editLecture(attribute): return .leftAligned(title: "", doneBlock: { _ in return }, initialValue: "")
            case .color: return .colorPick
            case .remark: return .textView(title: "")
            case .singleClass: return .singleClass
            case .padding: return .padding
            case .addButton, .resetButton, .syllabusButton, .deleteButton:
                return .button(title: "", color: UIColor.black, onClick: {  })
            case .singleClassTitle:
                return .leftAlignedLabel(string: "")
            }
        }
    }

    func getCellViewTypeFrom(cellType: CellType) -> CellViewType {
        switch cellType {
        case let .editLecture(attribute):
            return .leftAligned(title: attribute.titleName, doneBlock: doneBlockFor(attribute: attribute), initialValue: initialValueFor(attribute: attribute))
        case .color:
            return .colorPick
        case .remark:
            return .textView(title: "비고")
        case .singleClass:
            return .singleClass
        case .singleClassTitle:
            return .leftAlignedLabel(string: "시간 및 장소")
        case .padding:
            return .padding
        case .addButton:
            return .button(title: "+ 시간 추가", color: UIColor.black, onClick: { 
                self.currentLecture.classList.append(STSingleClass(time: STTime(day: 0, startPeriod: 0.0, duration: 1.0), place: ""))
                self.tableView.insertRows(at: [IndexPath(row: self.currentLecture.classList.count, section: self.sectionForSingleClass)], with: .automatic);
            })
        case .resetButton:
            return .button(title: "초기화", color: UIColor.red, onClick: { 
                let actions = [
                    UIAlertAction(title: "초기화", style: .destructive, handler: { _ in
                        self.resetButtonClicked()
                    }),
                    UIAlertAction(title: "취소", style: .cancel, handler: nil)
                ]
                STAlertView.showAlert(title: "강좌 초기화", message: "강좌를 원래 상태로 초기화하시겠습니까?", actions: actions)
            })
        case .syllabusButton:
            return .button(title: "강의계획서", color: UIColor.black,  onClick: { [errorHandler] in 
                let quarter = self.timetableManager.currentTimetable!.quarter
                let lecture = self.currentLecture
                let target = STTarget.GetSyllabus(params: .init(year: quarter.year, semester: quarter.semester, course_number: lecture.courseNumber ?? "", lecture_number: lecture.lectureNumber ?? ""))
                self.networkProvider.rx.request(target)
                    .map { result in result.url }
                    .subscribe(onSuccess: { [weak self] url in
                        guard let url = url else { return }
                        self?.showWebView(url)
                        }, onError: errorHandler.apiOnError)
                    .disposed(by: self.disposeBag)
            })
        case .deleteButton:
            return .button(title: "삭제", color: UIColor.red, onClick: { 
                let actions = [
                    UIAlertAction(title: "삭제", style: .destructive, handler: { [weak self] _ in
                        guard let self = self else { return }
                        if let index = self.timetableManager.currentTimetable?.lectureList.index(of: self.currentLecture) {
                            self.timetableManager.deleteLectureAtIndex(index)
                                .subscribe(onCompleted: { [weak self] in
                                    self?.navigationController?.popViewController(animated: true)
                                }, onError: { _ in }
                            ).disposed(by: self.disposeBag)
                        }
                    }),
                    UIAlertAction(title: "취소", style: .cancel, handler: nil)
                ]
                STAlertView.showAlert(title: "강좌 삭제", message: "강좌를 삭제하시겠습니까?", actions: actions)
            })
        }

    }

    func cellTypeAtIndexPath(_ indexPath : IndexPath) -> CellType {
        return .padding // should override
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UINib(nibName: "STLeftAlignedTextFieldCell", bundle: Bundle.main),
                           forCellReuseIdentifier: CellViewType.leftAligned(title: "", doneBlock: {_ in return }, initialValue: "").identifier)
        tableView.register(UINib(nibName: "STLeftAlignedLabelCell", bundle: Bundle.main), forCellReuseIdentifier: CellViewType.leftAlignedLabel(string: "").identifier)
        tableView.register(UINib(nibName: "STColorPickTableViewCell", bundle: Bundle.main),
                              forCellReuseIdentifier: CellViewType.colorPick.identifier)
        tableView.register(UINib(nibName: "STSingleClassTableViewCell", bundle: Bundle.main),
                              forCellReuseIdentifier: CellViewType.singleClass.identifier)
        tableView.register(UINib(nibName: "STSingleLectureButtonCell", bundle: Bundle.main),
                           forCellReuseIdentifier: CellViewType.button(title: "", color: UIColor.black, onClick: {  return }).identifier)
        tableView.register(UINib(nibName: "STTextViewTableViewCell", bundle: Bundle.main),
                              forCellReuseIdentifier: CellViewType.textView(title: "").identifier)
        tableView.register(STPaddingTableViewCell.self, forCellReuseIdentifier: CellViewType.padding.identifier)

        textviewCell = UINib(nibName: "STTextViewTableViewCell", bundle: Bundle.main).instantiate(withOwner: self, options: nil)[0] as! STTextViewTableViewCell

        self.tableView.backgroundColor = UIColor(white: 0.97, alpha: 1.0)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(STSingleLectureTableViewController.dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        self.tableView.addGestureRecognizer(tapGesture)
    }
    
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 15
        }
        return 10
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let type = cellTypeAtIndexPath(indexPath)
        let cellViewType = getCellViewTypeFrom(cellType: type)
        let tmpCell = tableView.dequeueReusableCell(withIdentifier: cellViewType.identifier, for: indexPath)
        switch cellViewType {
        case .colorPick:
            let cell =  tmpCell as! STColorPickTableViewCell
            cell.color = currentLecture.getColor()
            return cell
        case .padding:
            return tmpCell
        case .singleClass:
            let cell = tmpCell as! STSingleClassTableViewCell
            cell.singleClass = currentLecture.classList[indexPath.row - 1]
            cell.placeDoneBlock = { value in self.currentLecture.classList[indexPath.row - 1].place = value }
            cell.timeDoneBlock = { value in self.currentLecture.classList[indexPath.row - 1].time = value }
            cell.custom = true // Single Class Editable in non-custom
            cell.deleteLectureBlock = { 
                guard let indexPathNow = self.tableView.indexPath(for: cell) else {
                    return
                }
                self.currentLecture.classList.remove(at: indexPathNow.row - 1)
                tableView.deleteRows(at: [indexPathNow], with: .middle)
            }
            return cell
        case let .leftAligned(title, doneBlock, initialValue):
            let cell = tmpCell as! STLeftAlignedTextFieldCell
            cell.titleLabel.text = title
            cell.textField.text = initialValue
            cell.doneBlock = doneBlock
            cell.textField.keyboardType = .default
            cell.isEditableField = true
            if case let .editLecture(attribute) = type {
                switch attribute {
                case .credit:
                    cell.textField.keyboardType = .numberPad
                case .lectureNum, .courseNum:
                    cell.isEditableField = false
                default:
                    break
                }
            }
            return cell
        case let .textView(title):
            let cell = tmpCell as! STTextViewTableViewCell
            cell.doneBlock = { value in self.currentLecture.remark = value
            }
            cell.textView.text = self.currentLecture.remark
            cell.textView.placeholder = "(없음)"
            cell.titleLabel.text = title
            cell.tableView = self.tableView
            return cell
        case let .button(title, color, onClick):
            let cell = tmpCell as! STSingleLectureButtonCell
            cell.buttonAction = onClick
            cell.button.tintColor = color
            cell.button.setTitle(title, for: .normal)
            cell.button.titleLabel?.text = title
            return cell
        case let .leftAlignedLabel(string):
            let cell = tmpCell as! STLeftAlignedLabelCell
            cell.label.text = string
            return cell
        }
    }

    var textviewCell : STTextViewTableViewCell!

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cellType = cellTypeAtIndexPath(indexPath)
        if case CellType.remark = cellType {
            textviewCell.textView.text = STUtil.isEmptyOrNil(str: currentLecture.remark) ? "(없음)" : currentLecture.remark
            return textviewCell.textView.sizeThatFits(CGSize(width: textviewCell.textView.frame.width, height: 300)).height + 20
        }
        switch cellType.simpleCellViewType {
        case .leftAligned: return 40
        case .colorPick: return 40
        case .padding: return 4
        case .singleClass: return 60
        case .button: return 48
        case .textView: return 75
        case .leftAlignedLabel: return 36
        }
    }
    
    func triggerColorPicker() {
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "STColorPickerTableViewController") as! STColorPickerTableViewController
        viewController.color = currentLecture.getColor()
        viewController.colorIndex = currentLecture.colorIndex
        viewController.doneBlock = { colorIndex, color in
            self.currentLecture.color = color
            self.currentLecture.colorIndex = colorIndex
            self.tableView.reloadData()
        }
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func showWebView(_ url: String) {
        if #available(iOS 9.0, *) {
            let svc = SFSafariViewController(url: URL(string: url)!)
            self.present(svc, animated: true, completion: nil)
        } else {
            UIApplication.shared.openURL(URL(string: url)!)
        }
    }
    
    func resetButtonClicked() {
        return
    }
    
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
