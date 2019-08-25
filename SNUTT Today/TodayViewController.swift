//
//  TodayViewController.swift
//  SNUTT Today
//
//  Created by Rajin on 2017. 3. 8..
//  Copyright © 2017년 WaffleStudio. All rights reserved.
//

import UIKit
import NotificationCenter
import SwiftyUserDefaults

class TodayViewController: UIViewController, NCWidgetProviding {
    //TODO: iOS 9 Testing
    
    @IBOutlet weak var timetableView: STTimetableView!
    var maxHeight : CGFloat =  400.0

    @IBOutlet weak var descriptionLabel: UILabel!

    let sharedDefaults = UserDefaults(suiteName: "group.wafflestudio.TodayExtensionSharingDefaults")

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let extensionContext = self.extensionContext else {
            return
        }
        descriptionLabel.text = "SNUTT 시간표를 보기 위해서는 위의 더보기를 눌러주세요."

        updateTimetable()
        updateSetting()
        updateColorList()

        extensionContext.widgetLargestAvailableDisplayMode = NCWidgetDisplayMode.expanded
        let displayMode = extensionContext.widgetActiveDisplayMode
        let maxSize = extensionContext.widgetMaximumSize(for: displayMode)
        self.widgetActiveDisplayModeDidChange(displayMode, withMaximumSize: maxSize)

        NotificationCenter.default.addObserver(self, selector: #selector(userDefaultsDidChange), name: UserDefaults.didChangeNotification, object: nil)
    }

    @objc func userDefaultsDidChange (_ notification: Notification) {
        updateTimetable()
        updateSetting()
        updateColorList()
    }

    func updateTimetable() {
        timetableView.setTimetable(STDefaults[.currentTimetable])
    }

    func updateSetting() {
        let fitMode : STTimetableView.FitMode
        if STDefaults[.autoFit] {
            fitMode = .auto
        } else {
            let timeRange = STDefaults[.timeRange]
            let dayRange = STDefaults[.dayRange]
            let spec = STTimetableView.FitSpec(
                startPeriod: Int(timeRange[0]),
                endPeriod: Int(timeRange[1]) + 1,
                startDay: dayRange[0],
                endDay: dayRange[1]
            )
            fitMode = .manual(spec: spec)
        }
        timetableView.setFitMode(fitMode)
    }

    func updateColorList() {
        let colorList = STDefaults[.colorList] ?? STColorList(colorList: [], nameList: [])
        timetableView.setColorList(colorList)
    }

    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize){
        if (activeDisplayMode == NCWidgetDisplayMode.compact) {
            self.preferredContentSize = maxSize
            timetableView.isHidden = true
            descriptionLabel.isHidden = false
        }
        else {
            self.preferredContentSize = CGSize(width: 0, height: maxHeight)
            timetableView.isHidden = false
            descriptionLabel.isHidden = true
        }
    }

    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        DispatchQueue.main.async(execute: {
            self.updateTimetable()
            self.updateSetting()
        });

        completionHandler(NCUpdateResult.newData)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
