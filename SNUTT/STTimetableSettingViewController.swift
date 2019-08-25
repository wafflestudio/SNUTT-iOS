//
//  STTimetableSettingViewController.swift
//  SNUTT
//
//  Created by Rajin on 2016. 7. 27..
//  Copyright © 2016년 WaffleStudio. All rights reserved.
//

import UIKit
import TTRangeSlider
import RxSwift
import RxCocoa

class STTimetableSettingViewController: UITableViewController {

    let settingManager = AppContainer.resolver.resolve(STSettingManager.self)!

    let disposeBag = DisposeBag()

    @IBOutlet weak var trimmingSwitch: UISwitch!
    @IBOutlet weak var daySlider: TTRangeSlider!
    @IBOutlet weak var dayText: UILabel!
    @IBOutlet weak var timeSlider: TTRangeSlider!
    @IBOutlet weak var timeText: UILabel!
    
    func setInitialUI() {
        let dayRange = STDefaults[.dayRange]
        let timeRange = STDefaults[.timeRange]
        trimmingSwitch.isOn = STDefaults[.autoFit]

        daySlider.selectedMinimum = Float(dayRange[0])
        daySlider.selectedMaximum = Float(dayRange[1])
        timeSlider.selectedMinimum = Float(timeRange[0])
        timeSlider.selectedMaximum = Float(timeRange[1] - 1)
        
        daySlider.step = 1.0
        timeSlider.step = 1.0
        
        daySlider.numberFormatterOverride = STDayFormatter()
        
        daySlider.minDistance = 2.0
        timeSlider.minDistance = 7.0

        trimmingSwitch.rx.isOn
            .subscribe(onNext: {[weak self] isOn in
                guard let self = self else { return }
                let sliders : [TTRangeSlider?] = [self.daySlider, self.timeSlider]
                let textColor = isOn ? UIColor.gray : UIColor.black
                let tintColor = UIColor.lightGray
                let handleColor = isOn ? UIColor.lightGray : UIColor.black
                for slider in sliders {
                    slider?.isEnabled = !isOn
                    slider?.tintColor = tintColor
                    slider?.handleColor = handleColor
                    slider?.minLabelColour = handleColor
                    slider?.maxLabelColour = handleColor
                    slider?.tintColorBetweenHandles = handleColor
                }
                self.dayText.textColor = textColor
                self.timeText.textColor = textColor
                self.saveSetting()
            }).disposed(by: disposeBag)
    }
    
    func saveSetting() {
        let fitMode : STTimetableView.FitMode
        if trimmingSwitch.isOn {
            fitMode = .auto
        } else {
            let spec = STTimetableView.FitSpec(
                startPeriod: Int(timeSlider.selectedMinimum),
                endPeriod: Int(timeSlider.selectedMaximum + 1),
                startDay: Int(daySlider.selectedMinimum),
                endDay: Int(daySlider.selectedMaximum)
            )
            fitMode = .manual(spec: spec)
        }
        settingManager.fitMode = fitMode
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setInitialUI()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    override func willMove(toParent parent: UIViewController?) {
        if parent == nil { // check if it is popping from the navigation stack
            saveSetting()
        }
    }
    
    @IBAction func autoFitValueChanged(_ sender: AnyObject) {
        saveSetting()
    }
}
