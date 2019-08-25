//
//  STColorManager.swift
//  SNUTT
//
//  Created by Rajin on 2017. 3. 18..
//  Copyright © 2017년 WaffleStudio. All rights reserved.
//

import RxSwift
import RxCocoa

class STColorManager: ReactiveCompatible {

    init() {
        self.loadData()
        #if TODAY_EXTENSION
        #else
        self.updateData()
        #endif
    }

    let colorListSubject = BehaviorRelay<STColorList>(value: STColorList(colorList: [], nameList: []))

    var colorList: STColorList {
        get {
            return colorListSubject.value
        }
    }

    func loadData() {
        if let colorList = STDefaults[.colorList] {
            colorListSubject.accept(colorList)
        }
    }

    func saveData() {
        STDefaults[.colorList] = colorListSubject.value
    }
}

extension Reactive where Base == STColorManager {
    var colorList: Observable<STColorList> {
        return base.colorListSubject.asObservable()
    }
}
