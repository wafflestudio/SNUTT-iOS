//
//  STViewButton.swift
//  SNUTT
//
//  Created by Rajin on 2017. 4. 27..
//  Copyright © 2017년 WaffleStudio. All rights reserved.
//

import UIKit

@IBDesignable
class STViewButton: UIView {

    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    @IBInspectable var borderColor: UIColor? {
        didSet {
            layer.borderColor = borderColor?.cgColor
        }
    }

    @IBInspectable var pressedBgColor: UIColor?
    var origBgColor: UIColor!

    var buttonPressAction: (()->())? = nil

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    func setup() {
        let tapRecognizer = UITapGestureRecognizer(target: self, action:#selector(buttonPressed))
        self.addGestureRecognizer(tapRecognizer)
        origBgColor = self.backgroundColor
    }

    @objc func buttonPressed(gesture: UITapGestureRecognizer) {

        buttonPressAction?()
        self.backgroundColor = origBgColor
    }

    override func touchesBegan(_ presses: Set<UITouch>, with event: UIEvent?) {
        if let bgColor = pressedBgColor {
            self.backgroundColor = bgColor
        }
    }

    override func touchesEnded(_ presses: Set<UITouch>, with event: UIEvent?) {
        self.backgroundColor = origBgColor
    }

    override func touchesCancelled(_ presses: Set<UITouch>, with event: UIEvent?) {
        self.backgroundColor = origBgColor
    }
}
