//
//  STSettingManager.swift
//  SNUTT
//
//  Created by Rajin on 2019. 2. 24..
//  Copyright © 2019년 WaffleStudio. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

class STSettingManager: ReactiveCompatible {

    let fitModeSubject = BehaviorRelay<STTimetableView.FitMode>(value: .auto)

    init() {
        let timeRange = STDefaults[.timeRange]
        let dayRange = STDefaults[.dayRange]
        if STDefaults[.autoFit] {
            fitModeSubject.accept(.auto)
        } else {
            let spec = STTimetableView.FitSpec(
                startPeriod: Int(timeRange[0]),
                endPeriod: Int(timeRange[1]) + 1,
                startDay: dayRange[0],
                endDay: dayRange[1]
            )
            fitModeSubject.accept(.manual(spec: spec))
        }
    }

    var fitMode: STTimetableView.FitMode {
        get {
            return fitModeSubject.value
        }
        set {
            switch newValue {
            case .auto:
                STDefaults[.autoFit] = true
            case .manual(let spec):
                STDefaults[.autoFit] = false
                STDefaults[.timeRange] = [
                    Double(spec.startPeriod),
                    Double(spec.endPeriod) - 1
                ]
                STDefaults[.dayRange] = [
                    Int(spec.startDay),
                    Int(spec.endDay)
                ]
            }
            fitModeSubject.accept(newValue)
        }
    }
}

extension Reactive where Base == STSettingManager {
    var fitMode: Observable<STTimetableView.FitMode> {
        return base.fitModeSubject.asObservable()
    }
}
