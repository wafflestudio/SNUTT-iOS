//
//  STTimetableView.swift
//  SNUTT
//
//  Created by Rajin on 2019. 2. 2..
//  Copyright © 2019년 WaffleStudio. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import RxSwift
import RxCocoa

class STTimetableView : UIView {
    let disposeBag = DisposeBag()

    let columnHeader = UIView()
    let rowHeader = UIView()
    let cornerSizeView = UIView() // space at the top left corner
    let lectureContainer = UIView()
    let gridView = STTimetableGridView()
    var cornerSizeWidthConstraint: Constraint!
    var cornerSizeHeightConstraint: Constraint!
    var lectureViews : [CompactLecture: [STSingleClassView]] = [:]

    let lectureListSubject = BehaviorRelay<[CompactLecture]>(value: [])
    let fitModeSubject = BehaviorRelay<FitMode>(value: .auto)
    let colorListSubject = BehaviorRelay<STColorList>(value: STColorList(colorList: [], nameList: []))

    let clickedLectureRelay = PublishRelay<String?>()
    let longPressedLectureRelay = PublishRelay<String?>()

    let columnHeaderCells = ["월", "화", "수", "목", "금", "토", "일"].map { text -> UILabel in
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 11)
        label.textColor = UIColor.init(white: 0.3, alpha: 1.0)
        label.text = text
        return label
    }
    let rowHeaderCells = (0...STPeriod.periodNum).map { period -> UILabel in
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor.init(white: 0.3, alpha: 1.0)
        label.text = period.shortPeriodSring()
        return label
    }

    enum FitMode {
        case auto
        case manual(spec: FitSpec)
    }

    struct FitSpec : Equatable {
        var startPeriod: Int
        // endPeriod is the exact time.
        // => startPeriod < endPeriod (cannot be equal)
        var endPeriod: Int
        var startDay: Int
        var endDay: Int

        // Computed properties
        var rowNum: Int {
            return endPeriod - startPeriod
        }
        var columnNum: Int {
            return endDay - startDay + 1
        }
        var heightRatioForHeader: Float {
            return 0.67
        }
        var widthForHeader: Float {
            return 25.0
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initInternal()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        initInternal()
    }

    func initInternal() {
        addSubview(gridView)
        addSubview(cornerSizeView)
        addSubview(columnHeader)
        addSubview(rowHeader)
        addSubview(lectureContainer)

        cornerSizeView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            self.cornerSizeWidthConstraint = make.width.equalTo(0).constraint
            self.cornerSizeHeightConstraint = make.height.equalToSuperview().multipliedBy(0).constraint
        }
        columnHeader.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.bottom.equalTo(cornerSizeView)
            make.leading.equalTo(cornerSizeView.snp.trailing)
            make.trailing.equalToSuperview()
        }
        rowHeader.snp.makeConstraints { make in
            make.top.equalTo(cornerSizeView.snp.bottom)
            make.bottom.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalTo(cornerSizeView)
        }
        gridView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        lectureContainer.snp.makeConstraints { make in
            make.top.equalTo(cornerSizeView.snp.bottom)
            make.bottom.trailing.equalToSuperview()
            make.leading.equalTo(cornerSizeView.snp.trailing)
        }
        lectureContainer.clipsToBounds = true

        Observable.combineLatest(lectureListSubject, fitModeSubject, colorListSubject, resultSelector: { (lectureList, fitMode, colorList) in
            (lectureList, fitMode, colorList)
        }).subscribe(onNext: { [weak self] (lectureList, fitMode, colorList) in
            guard let self = self else { return }
            var fitSpec: FitSpec
            switch fitMode {
            case .auto:
                fitSpec = self.getAutoFitSpec(lectureList: lectureList)
            case .manual(let spec):
                fitSpec = spec
            }
            self.updateBackground(fitSpec: fitSpec)
            self.updateLecture(lectureList: lectureList, fitSpec: fitSpec, colorList: colorList)
        }).disposed(by: disposeBag)

    }

    var backgroundSpec: FitSpec? = nil
    func updateBackground(fitSpec spec: FitSpec) {
        if self.backgroundSpec == spec {
            return
        }
        self.backgroundSpec = spec

        // columnHeader
        columnHeader.subviews.forEach {
            $0.removeFromSuperview()
        }
        let validColumnHeaderCells = columnHeaderCells[spec.startDay...spec.endDay]
        for (index, cell) in validColumnHeaderCells.enumerated() {
            columnHeader.addSubview(cell)
            cell.snp.makeConstraints { make in
                make.centerY.equalToSuperview()
                make.centerX.equalTo(columnHeader.snp.trailing).multipliedBy(Float(2*index + 1) / Float(2 * validColumnHeaderCells.count))
            }
        }
        // rowHeader
        rowHeader.subviews.forEach {
            $0.removeFromSuperview()
        }
        let validRowHeaderCells = rowHeaderCells[spec.startPeriod..<spec.endPeriod]
        for (index, cell) in validRowHeaderCells.enumerated() {
            rowHeader.addSubview(cell)
            cell.snp.makeConstraints { make in
                make.trailing.equalToSuperview().offset(-4)
                make.bottom.equalTo(rowHeader.snp.bottom).multipliedBy(Float(2*index + 1) / Float(2 * validRowHeaderCells.count))
            }
        }
        // sizeView
        let columnHeaderHeightRatio = spec.heightRatioForHeader / (Float(spec.rowNum) + spec.heightRatioForHeader)
        cornerSizeWidthConstraint.update(offset: spec.widthForHeader)
        cornerSizeHeightConstraint.deactivate()
        cornerSizeView.snp.makeConstraints { make in
            self.cornerSizeHeightConstraint =
                make.height.equalToSuperview().multipliedBy(columnHeaderHeightRatio).constraint
        }
        // gridView
        gridView.spec = spec
        gridView.setNeedsDisplay()
    }

    func setTimetable(_ timetable : STTimetable?, tempLecture: STLecture? = nil) {
        let lectureList = (timetable?.lectureList ?? []) + [tempLecture].compactMap { $0 }
        lectureListSubject.accept(lectureList.map { $0.toCompactLecture() })
    }

    func setCompactLectureList(_ lectureList: [CompactLecture]) {
        lectureListSubject.accept(lectureList)
    }

    func setFitMode(_ mode: FitMode) {
        fitModeSubject.accept(mode)
    }

    func setColorList(_ colorList: STColorList) {
        colorListSubject.accept(colorList)
    }

    private func getAutoFitSpec(lectureList: [CompactLecture]) -> FitSpec {
        if lectureList.count == 0 {
            return FitSpec(startPeriod: 1, endPeriod: 12, startDay: 0, endDay: 4)
        } else {
            var startPeriod = 2, endPeriod = 10
            var endDay = 4
            for lecture in lectureList {
                for singleClass in lecture.singleClassList {
                    startPeriod = min(startPeriod, Int(singleClass.time.startPeriod))
                    endPeriod = max(endPeriod, Int(singleClass.time.endPeriod + 0.5))
                    endDay = max(endDay, singleClass.time.day.rawValue)
                }
            }
            return FitSpec(startPeriod: startPeriod, endPeriod: endPeriod, startDay: 0, endDay: endDay)
        }
    }

    private func updateLecture(lectureList: [CompactLecture], fitSpec spec: FitSpec, colorList: STColorList) {
        var oldLectureViews = self.lectureViews
        var newLectureViews : [CompactLecture: [STSingleClassView]] = [:]
        for lecture in lectureList {
            if let views = oldLectureViews[lecture] {
                for (index, view) in views.enumerated() {
                    let singleClass = lecture.singleClassList[index]
                    setData(to: view, lecture: lecture, singleClass: singleClass, fitSpec: spec, colorList: colorList)
                }
                newLectureViews[lecture] = views
                oldLectureViews.removeValue(forKey: lecture)
            } else {
                // create views
                let views = lecture.singleClassList.map { singleClass -> STSingleClassView in
                    let view = createSingleLectureView(lecture: lecture, singleClass: singleClass, fitspec: spec, colorList: colorList)
                    return view
                }
                newLectureViews[lecture] = views
            }
        }
        for (key, views) in oldLectureViews {
            views.forEach { $0.removeFromSuperview() }
        }
        self.lectureViews = newLectureViews
    }

    private func createSingleLectureView(lecture: CompactLecture, singleClass : STSingleClass, fitspec spec: FitSpec, colorList: STColorList) -> STSingleClassView {
        let view = STSingleClassView()
        lectureContainer.addSubview(view)
        setData(to: view, lecture: lecture, singleClass: singleClass, fitSpec: spec, colorList: colorList)
        return view
    }

    private func setData(to view: STSingleClassView, lecture: CompactLecture, singleClass: STSingleClass, fitSpec: FitSpec, colorList: STColorList) {
        view.setData(lecture: lecture, singleClass: singleClass, fitSpec: fitSpec, colorList: colorList)
        view.onClick = { [weak self] in
            guard let self = self else { return }
            self.clickedLectureRelay.accept(lecture.id)
        }
        view.onLongPress = { [weak self] in
            guard let self = self else { return }
            self.longPressedLectureRelay.accept(lecture.id)
        }
    }
}

struct CompactLecture : Hashable {
    var id : String?
    var title: String
    var color: STColor? = nil
    var colorIndex: Int
    var singleClassList: [STSingleClass]

    func getColor(colorList: STColorList) -> STColor {
        if colorIndex == 0 {
            return color ?? STColor()
        } else if (colorIndex <= colorList.colorList.count && colorIndex >= 1) {
            return colorList.colorList[colorIndex - 1]
        } else {
            return STColor()
        }
    }
}

extension STLecture {
    func toCompactLecture() -> CompactLecture {
        return CompactLecture(id: id, title: title, color: color, colorIndex: colorIndex, singleClassList: self.classList)
    }
}
