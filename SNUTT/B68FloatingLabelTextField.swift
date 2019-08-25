//
//  B68UIFloatLabelTextField.swift
//  UIFloatLabelTextInput
//
//  Created by Dirk Fabisch on 07.09.14.
//  Copyright (c) 2014 Dirk Fabisch. All rights reserved.
//

import UIKit

public class B68UIFloatLabelTextField: UITextField {

    /**
     The floating label that is displayed above the text field when there is other
     text in the text field.
     */
    public var floatingLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 0))


    /**
     The color of the floating label displayed above the text field when it is in
     an active state (i.e. the associated text view is first responder).

     @discussion Note: Default Color is blue.
     */
    @IBInspectable public var activeTextColorfloatingLabel : UIColor = UIColor.blue {
        didSet {
            floatingLabel.textColor = activeTextColorfloatingLabel
        }
    }
    /**
     The color of the floating label displayed above the text field when it is in
     an inactive state (i.e. the associated text view is not first responder).

     @discussion Note: 70% gray is used by default if this is nil.
     */
    @IBInspectable public var inactiveTextColorfloatingLabel : UIColor = UIColor(white: 0.7, alpha: 1.0) {
        didSet {
            floatingLabel.textColor = inactiveTextColorfloatingLabel
        }
    }

    /**
     The default dynamic test size
     */
    public var placeHolderTextSize : UIFont.TextStyle = .caption2 {
        didSet {
            floatingLabel.font = UIFont.preferredFont(forTextStyle: placeHolderTextSize)
        }
    }

    /**
     Used to cache the placeholder string.
     */
    private var cachedPlaceholder : String = ""

    /**
     Used to draw the placeholder string if necessary. Starting value is true.
     */
    private var shouldDrawPlaceholder = true

    /**
     default padding for floatingLabel
     */
    public var verticalPadding : CGFloat = 0
    public var horizontalPadding : CGFloat = 0


    //MARK: Initializer
    //MARK: Programmatic Initializer

    override convenience init(frame: CGRect) {
        self.init(frame: frame)
        setup()
    }

    //MARK: Nib/Storyboard Initializers
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        setup()
    }

    //MARK: Unsupported Initializers
    init () {
        fatalError("Using the init() initializer directly is not supported. use init(frame:) instead")
    }

    //MARK: Deinit
    deinit {
        // remove observer
        NotificationCenter.default.removeObserver(self)
    }


    //MARK: Setter & Getter
    override public var placeholder : String? {
        get {
            return super.placeholder
        }
        set (newValue) {
            super.placeholder = newValue
            if (cachedPlaceholder != newValue) {
                cachedPlaceholder = newValue!
                floatingLabel.text = self.cachedPlaceholder as String
                floatingLabel.sizeToFit()
            }
        }
    }

    override public var hasText: Bool {
        return !(text?.isEmpty ?? true)
    }

    //MARK: Setup
    private func setup() {
        setupObservers()
        setupFloatingLabel()
        applyFonts()
        setupViewDefaults()
    }

    private func setupObservers() {
        NotificationCenter.default.addObserver(self, selector:Selector("textFieldTextDidChange:"), name: UITextField.textDidChangeNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector:Selector("fontSizeDidChange:"), name: UIContentSizeCategory.didChangeNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector:Selector("textFieldTextDidBeginEditing:"), name: UITextField.textDidBeginEditingNotification, object: self)
        NotificationCenter.default.addObserver(self, selector:Selector("textFieldTextDidEndEditing:"), name: UITextField.textDidEndEditingNotification, object: self)
    }

    private func setupFloatingLabel() {
        // Create the floating label instance and add it to the view
        floatingLabel.alpha = 1
        floatingLabel.center = CGPoint(x: horizontalPadding, y: verticalPadding)
        addSubview(floatingLabel)
        //TODO: Set tint color instead of default value

        // Setup default colors for the floating label states
        floatingLabel.textColor = inactiveTextColorfloatingLabel
        floatingLabel.alpha = 0

    }

    private func applyFonts() {

        // set floatingLabel to have the same font as the textfield
        floatingLabel.font = font?.withSize(UIFont.preferredFont(forTextStyle: placeHolderTextSize).pointSize)
    }

    private func setupViewDefaults() {

        // set vertical padding
        verticalPadding = 0.5 * self.frame.height

        // make sure the placeholder setter methods are called
        if let ph = placeholder {
            placeholder = ph
        } else {
            placeholder = ""
        }
    }

    //MARK: - Drawing & Animations
    override public func layoutSubviews() {
        super.layoutSubviews()
        if (isFirstResponder && !hasText) {
            hideFloatingLabel()
        } else if(hasText) {
            showFloatingLabelWithAnimation(isAnimated: true)
        }
    }

    func showFloatingLabelWithAnimation(isAnimated : Bool)
    {
        let fl_frame = CGRect(
            x: horizontalPadding,
            y: 0,
            width: self.floatingLabel.frame.width,
            height: self.floatingLabel.frame.height
        )
        if (isAnimated) {
            let options : UIView.AnimationOptions = [.beginFromCurrentState, .curveEaseOut]
            UIView.animate(withDuration: 0.2, delay: 0, options: options, animations: {
                self.floatingLabel.alpha = 1
                self.floatingLabel.frame = fl_frame
            }, completion: nil)
        } else {
            self.floatingLabel.alpha = 1
            self.floatingLabel.frame = fl_frame
        }
    }

    func hideFloatingLabel () {
        let fl_frame = CGRect(
            x: horizontalPadding,
            y: verticalPadding,
            width: self.floatingLabel.frame.width,
            height: self.floatingLabel.frame.height
        )
        let options: UIView.AnimationOptions = [.beginFromCurrentState, .curveEaseIn]
        UIView.animate(withDuration: 0.2, delay: 0, options: options, animations: {
            self.floatingLabel.alpha = 0
            self.floatingLabel.frame = fl_frame
        }, completion: nil
        )
    }


    //MARK: - Auto Layout
    override public var intrinsicContentSize: CGSize {
        return sizeThatFits(frame.size)
    }

    // Adds padding so these text fields align with B68FloatingPlaceholderTextView's
    public override func textRect(forBounds bounds: CGRect) -> CGRect {
        return super.textRect(forBounds: bounds).inset(by: floatingLabelInsets())
    }

    // Adds padding so these text fields align with B68FloatingPlaceholderTextView's
    override public func editingRect(forBounds bounds: CGRect) -> CGRect {
        return super.editingRect(forBounds: bounds).inset(by: floatingLabelInsets())
    }

    //MARK: - Helpers
    private func floatingLabelInsets() -> UIEdgeInsets {
        floatingLabel.sizeToFit()
        return UIEdgeInsets(
            top: floatingLabel.font.lineHeight,
            left: horizontalPadding,
            bottom: 0,
            right: horizontalPadding)
    }


    //MARK: - Observers
    func textFieldTextDidChange(notification : NSNotification) {
        let previousShouldDrawPlaceholderValue = shouldDrawPlaceholder
        shouldDrawPlaceholder = !hasText

        // Only redraw if self.shouldDrawPlaceholder value was changed
        if (previousShouldDrawPlaceholderValue != shouldDrawPlaceholder) {
            if (self.shouldDrawPlaceholder) {
                hideFloatingLabel()
            } else {
                showFloatingLabelWithAnimation(isAnimated: true)
            }
        }
    }
    //MARK: TextField Editing Observer
    func textFieldTextDidEndEditing(notification : NSNotification) {
        if (hasText)  {
            floatingLabel.textColor = inactiveTextColorfloatingLabel
        }
    }

    func textFieldTextDidBeginEditing(notification : NSNotification) {
        floatingLabel.textColor = activeTextColorfloatingLabel
    }

    //MARK: Font Size Change Oberver
    private func fontSizeDidChange (notification : NSNotification) {
        applyFonts()
        invalidateIntrinsicContentSize()
        setNeedsLayout()
    }

}
