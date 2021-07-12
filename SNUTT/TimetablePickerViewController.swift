//
//  TimetablePickerViewController.swift
//  SNUTT
//
//  Created by Jinsup Keum on 2021/07/07.
//  Copyright © 2021 WaffleStudio. All rights reserved.
//

import UIKit

protocol TimetablePickerViewControllerDelegate: UIViewController {
    func changeSemester(_ controller: TimetablePickerViewController, index: Int)
}

class TimetablePickerViewController: UIViewController {
    
    weak var delegate: TimetablePickerViewControllerDelegate?
    
    var semesterList: [STQuarter] = []
    var selectedSemesterIndex = 0

    @IBOutlet weak var semesterPickerView: UIPickerView!
    
    @IBAction func selectSemester(_ sender: UIButton) {
        delegate?.changeSemester(self, index: selectedSemesterIndex)
        
        dismiss(animated: true)
    }
    
    @IBAction func cancel(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    
    var semesterListInString: [String] {
        return semesterList.map({ semseter in
            return semseter.longString()
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        semesterPickerView.delegate = self
        semesterPickerView.dataSource = self
        
        semesterPickerView.selectRow(selectedSemesterIndex, inComponent: 0, animated: true)
    }
    
    func setSemesterList(list: [STQuarter]) {
        semesterList = list
    }
    
    func setSelectedSemester(index: Int?) {
        selectedSemesterIndex = index ?? 0
    }
}

extension TimetablePickerViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return semesterList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return semesterListInString[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 32
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedSemesterIndex = row
    }
}
