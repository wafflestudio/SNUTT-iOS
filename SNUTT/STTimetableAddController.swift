//
//  STTimetableAddController.swift
//  SNUTT
//
//  Created by Rajin on 2016. 1. 8..
//  Copyright © 2016년 WaffleStudio. All rights reserved.
//

import UIKit

class STTimetableAddController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var semesterPicker: UIPickerView!

    let courseBookListManager = AppContainer.resolver.resolve(STCourseBookListManager.self)!
    
    weak var timetableListController : STTimetableListController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        STEventCenter.sharedInstance.addObserver(self, selector: #selector(self.reloadCourseBook), event: STEvent.CourseBookUpdated, object: nil)
        // Do any additional setup after loading the view.
        semesterPicker.delegate = self
        semesterPicker.dataSource = self
    }
    
    @objc func reloadCourseBook() {
        semesterPicker.reloadAllComponents()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func canceclButtonClicked(_ sender: UIBarButtonItem) {
        self.view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func saveButtonClicked(_ sender: UIBarButtonItem) {
        let index = semesterPicker.selectedRow(inComponent: 0)
        let selectedCourseBook = courseBookListManager.courseBookList[index]
        let title = titleTextField.text
        if (title == nil || title == "") {
            STAlertView.showAlert(title: "시간표 추가 실패", message: "시간표 이름을 적어주세요.")
            return
        }
        self.view.endEditing(true)
        timetableListController.addTimetable(title!, courseBook: selectedCourseBook)
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - UIPickerViewDataSource
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return courseBookListManager.courseBookList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return courseBookListManager.courseBookList[row].quarter.longString()
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
