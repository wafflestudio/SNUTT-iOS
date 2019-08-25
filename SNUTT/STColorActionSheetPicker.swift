//
//  STColorActionSheetPicker.swift
//  SNUTT
//
//  Created by Rajin on 2017. 2. 14..
//  Copyright © 2017년 WaffleStudio. All rights reserved.
//

import Foundation
import Foundation
import ActionSheetPicker_3_0

class STColorActionSheetPicker : NSObject, ActionSheetCustomPickerDelegate {
    
    var doneBlock : ((Int) -> Void)?
    var cancelBlock : (() -> Void)?
    var selectedBlock: ((Int)->Void)?
    var initialColorIndex : Int

    let colorManager = AppContainer.resolver.resolve(STColorManager.self)!

    var colorList : [STColor]
    var nameList : [String]

    init(initialColorIndex : Int, doneBlock: ((Int) -> Void)?, cancelBlock: (() -> Void)?, selectedBlock: ((Int)->Void)?) {
        self.doneBlock = doneBlock
        self.cancelBlock = cancelBlock
        self.selectedBlock = selectedBlock
        self.initialColorIndex = initialColorIndex
        colorList = colorManager.colorList.colorList
        nameList = colorManager.colorList.nameList
        super.init()
    }

    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        switch component {
        case 0:
            let attribute = [NSAttributedString.Key.foregroundColor: colorList[row].bgColor.lighten(byPercentage: 0.4)]
            return NSAttributedString(string: nameList[row], attributes: attribute)
        default: return nil
        }
    }

    func onePixelImageWithColor(_ color : UIColor) -> UIImage {
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGImageAlphaInfo.premultipliedLast
        let context = CGContext(data: nil, width: 1, height: 1, bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)!
        context.setFillColor(color.cgColor)
        context.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
        let image = UIImage(cgImage: context.makeImage()!)
        return image
    }

    func actionSheetPicker(_ actionSheetPicker: AbstractActionSheetPicker!, configurePickerView pickerView: UIPickerView!) {
        pickerView.tintColor = UIColor.white
        let bgImageColor = UIColor.black.withAlphaComponent(0.2)
        actionSheetPicker.toolbar.setBackgroundImage(onePixelImageWithColor(bgImageColor),
                                                     forToolbarPosition: UIBarPosition.bottom,
                                                     barMetrics: UIBarMetrics.default)
        actionSheetPicker.toolbar.tintColor = UIColor.white
        actionSheetPicker.toolbar.barTintColor = UIColor.white

        if (initialColorIndex == 0) {
            pickerView.selectRow(0, inComponent: 0, animated: false)
            selectedBlock?(1)
        } else {
            pickerView.selectRow(initialColorIndex-1, inComponent: 0, animated: false)
        }
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0: return nameList.count
        default: return 0
        }
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedBlock?(row + 1)
    }

    func actionSheetPickerDidSucceed(_ actionSheetPicker: AbstractActionSheetPicker!, origin: AnyObject!) {
        let pickerView = actionSheetPicker.pickerView as! UIPickerView
        let index = pickerView.selectedRow(inComponent: 0)
        doneBlock?(index + 1)
    }

    func actionSheetPickerDidCancel(_ actionSheetPicker: AbstractActionSheetPicker!, origin: AnyObject!) {
        cancelBlock?()
    }

    internal static func showWithColor(_ colorIndex: Int, doneBlock: ((Int) -> Void)?, cancelBlock: (() -> Void)?, selectedBlock: ((Int)->Void)?, origin : AnyObject! ) {
        let colorPickerDelegate = STColorActionSheetPicker(initialColorIndex: colorIndex, doneBlock: doneBlock, cancelBlock: cancelBlock, selectedBlock: selectedBlock)
        let actionSheetPicker = ActionSheetCustomPicker()
        
        let overlayBlack = UIColor.black.withAlphaComponent(0.3)
        actionSheetPicker.pickerBackgroundColor = overlayBlack
        actionSheetPicker.delegate = colorPickerDelegate
        actionSheetPicker.hideCancel = false
        
        actionSheetPicker.tapDismissAction = TapAction.cancel
        
        actionSheetPicker.show()
    }
}
