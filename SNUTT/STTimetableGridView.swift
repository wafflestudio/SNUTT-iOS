//
//  STTimetableGridView.swift
//  SNUTT
//
//  Created by Rajin on 2019. 2. 4..
//  Copyright © 2019년 WaffleStudio. All rights reserved.
//

import Foundation
import UIKit

class STTimetableGridView : UIView {
    var spec: STTimetableView.FitSpec?

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.white
        self.contentMode = .redraw
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        guard let context = UIGraphicsGetCurrentContext(), let spec = spec else {
            return
        }
        context.setStrokeColor(CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: [0.4,0.4,0.4,1.0])!)

        let contentWidth = rect.width
        let contentHeight = rect.height

        let widthPerColumn = (contentWidth - CGFloat(spec.widthForHeader)) / CGFloat(spec.columnNum)
        let widthForHeader = CGFloat(spec.widthForHeader)
        let heightPerRow = contentHeight / (CGFloat(spec.rowNum) + CGFloat(spec.heightRatioForHeader))
        let heightForHeader = CGFloat(spec.heightRatioForHeader) * heightPerRow

        // horizontal line

        let darkgrayColor = CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: [0.9215,0.9215,0.9215,1.0])!
        let grayColor = CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: [0.953,0.953,0.953,1.0])!
        for i in 0..<(spec.rowNum*2) {
            let y = heightForHeader + heightPerRow * CGFloat(i) / 2.0
            if i % 2 == 0 {
                context.setStrokeColor(darkgrayColor)
                context.drawSolidLine(st_x: 0, st_y: y, en_x: contentWidth, en_y: y)
            } else {
                context.setStrokeColor(grayColor)
                context.drawSolidLine(st_x: widthForHeader, st_y: y, en_x: contentWidth, en_y: y)
            }
        }

        context.setStrokeColor(grayColor);

        // vertical line
        for i in 0..<spec.columnNum {
            let x = widthForHeader + widthPerColumn * CGFloat(i)
            context.drawSolidLine(st_x: x, st_y: 0, en_x: x, en_y: contentHeight)
        }
    }
}

extension CGContext {
    func drawSolidLine(st_x : CGFloat, st_y : CGFloat, en_x : CGFloat, en_y : CGFloat, width: CGFloat = 1.0) {
        setLineDash(phase: 0.0, lengths: [])
        setLineWidth(width)
        move(to: CGPoint(x: st_x, y: st_y))
        addLine(to: CGPoint(x: en_x, y: en_y))
        strokePath()
    }

    func drawDashedLine(st_x : CGFloat, st_y : CGFloat, en_x : CGFloat, en_y : CGFloat, width: CGFloat = 1.0) {
        setLineDash(phase: 0.0, lengths: [2.0, 2.0])
        setLineWidth(width)
        move(to: CGPoint(x: st_x, y: st_y))
        addLine(to: CGPoint(x: en_x, y: en_y))
        strokePath()
    }
}
