//
//  STSingleClassView.swift
//  SNUTT
//
//  Created by Rajin on 2019. 2. 4..
//  Copyright © 2019년 WaffleStudio. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import RxCocoa
import RxSwift
import RxGesture

class STSingleClassView : UIView {
    let label = UILabel()
    let disposeBag = DisposeBag()

    var onClick: (()->())? = nil
    var onLongPress: (()->())? = nil
    private var blockClickEvent = false

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(label)
        label.snp.makeConstraints { make in
            make.edges.equalTo(self.snp.margins)
        }
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .center
        label.minimumScaleFactor = 0.8
        label.numberOfLines = -1
        let inset : CGFloat = isLargerThanSE() ? 5.0 : 4.0
        self.layoutMargins = UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
        self.rx.longPressGesture(configuration: { recognizer, _ in
            recognizer.minimumPressDuration = 0.0
        }).subscribe(onNext: { [weak self] gesture in
                guard let self = self else { return }
                switch gesture.state {
                case .began:
                    self.blockClickEvent = false
                case .ended:
                    if (!self.blockClickEvent) {
                        self.onClick?()
                    }
                default:
                    break
                }
            }).disposed(by: disposeBag)

        self.rx.longPressGesture()
            .when(.began)
            .subscribe(onNext: { [weak self] _ in
                self?.onLongPress?()
                self?.blockClickEvent = true
            }).disposed(by: disposeBag)

    }

    func setData(lecture: CompactLecture, singleClass: STSingleClass, fitSpec spec: STTimetableView.FitSpec, colorList: STColorList) {
        setText(lectureTitle: lecture.title, place: singleClass.place)
        setColor(lecture: lecture, colorList: colorList)
        setConstraints(time: singleClass.time, fitSpec: spec)
    }

    var lectureTitle: String = ""
    var place: String = ""

    private func setText(lectureTitle: String, place: String) {
        if self.lectureTitle == lectureTitle && self.place == place {
            return
        }
        self.lectureTitle = lectureTitle
        self.place = place

        var text = NSMutableAttributedString()
        if !lectureTitle.isEmpty {
            let font = UIFont.systemFont(ofSize: 10.0)
            text.append(NSAttributedString(string: lectureTitle.breakOnlyAtNewLineAndSpace, attributes: [NSAttributedString.Key.font: font]))
        }
        if !place.isEmpty {
            var size : CGFloat
            if isLargerThanSE() {
                if place.count >= 8 {
                    size = 10.0
                } else {
                    size = 11.0
                }
            } else {
                if place.count >= 8 {
                    size = 9.0
                } else {
                    size = 10.0
                }
            }
            let font = UIFont.boldSystemFont(ofSize: size)
            if text.length != 0 {
                text.append(NSAttributedString(string: "\n"))
            }
            text.append(NSAttributedString(string: place.breakOnlyAtNewLineAndSpace, attributes: [NSAttributedString.Key.font: font]))
        }

        label.attributedText = text
        label.baselineAdjustment = .alignCenters
    }

    private func setColor(lecture: CompactLecture, colorList: STColorList) {
        let color = lecture.getColor(colorList: colorList)
        self.backgroundColor = color.bgColor
        label.textColor = color.fgColor
    }

    private var time: STTime? = nil
    private var spec: STTimetableView.FitSpec? = nil

    private func setConstraints(time: STTime, fitSpec spec: STTimetableView.FitSpec) {
        if self.time == time && self.spec == spec {
            return
        }
        self.time = time
        self.spec = spec
        self.snp.removeConstraints()
        guard let superview = self.superview else { return }
        self.snp.makeConstraints { make in
            let leadingMultiplier = Float(time.day.rawValue - spec.startDay) / Float(spec.columnNum)
            if leadingMultiplier == Float(0) {
                make.leading.equalTo(superview.snp.leading)
            } else {
                make.leading.equalTo(superview.snp.trailing)
                    .multipliedBy(leadingMultiplier)
            }
            let trailingMultiplier = Float(time.day.rawValue - spec.startDay + 1) / Float(spec.columnNum)
            if trailingMultiplier == Float(0) {
                make.trailing.equalTo(superview.snp.leading)
            } else {
                make.trailing.equalTo(superview.snp.trailing)
                    .multipliedBy(trailingMultiplier)
            }
            let topMultiplier = (time.startPeriod - Double(spec.startPeriod)) / Double(spec.rowNum)
            if topMultiplier == Double(0) {
                make.top.equalToSuperview()
            } else {
                make.top.equalTo(superview.snp.bottom)
                    .multipliedBy(topMultiplier)
            }
            let bottomMultiplier = (time.endPeriod - Double(spec.startPeriod)) / Double(spec.rowNum)
            if bottomMultiplier == Double(0) {
                make.bottom.equalTo(superview.snp.top)
            } else {
                make.bottom.equalTo(superview.snp.bottom)
                    .multipliedBy(bottomMultiplier)
            }
        }
    }
}
