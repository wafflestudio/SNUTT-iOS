//
//  STAlertView.swift
//  SNUTT
//
//  Created by Rajin on 2016. 8. 21..
//  Copyright © 2016년 WaffleStudio. All rights reserved.
//

import Foundation
import UIKit

class STAlertView {
    
    // Possible TODO:
    // It does not do anything else other than show the alertview.
    // It would be good idea to make the alertview as stack internally and show them one by one,
    // or there can be other solutions.
    
    static fileprivate func createAlert(title: String, message: String) -> UIAlertController {
        return UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
    }
    
    static fileprivate func showAlert(_ alert: UIAlertController) {
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            while true {
                while let presentedViewController = topController.presentedViewController {
                    topController = presentedViewController
                }
                if topController is UIAlertController {
                    let topAlertController = topController as! UIAlertController
                    if topAlertController.actions.count == 0 {
                        topController.dismiss(animated: false, completion: {
                            showAlert(alert)
                        })
                        return
                    }
                }
                topController.present(alert, animated: true, completion: nil)
                return
            }
        }
    }
    
    static func showAlert(title: String, message: String) {
        let alert = STAlertView.createAlert(title: title, message: message)
        alert.addAction(UIAlertAction(title: "확인", style: UIAlertAction.Style.default, handler: nil))
        STAlertView.showAlert(alert)
    }
    
    static func showAlert(title: String, message: String, actions: [UIAlertAction]) {
        let alert = STAlertView.createAlert(title: title, message: message)
        for it in actions {
            alert.addAction(it)
        }
        STAlertView.showAlert(alert)
    }
    static func showAlert(title: String, message: String, configAlert: (UIAlertController) -> ()) {
        let alert = STAlertView.createAlert(title: title, message: message)
        configAlert(alert)
        STAlertView.showAlert(alert)
    }

    static func showLoading(title: String) -> UIAlertController {
        let pending = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        pending.preferredStyle

        let indicator = UIActivityIndicatorView()
        indicator.translatesAutoresizingMaskIntoConstraints = false
        pending.view.addSubview(indicator)

        let views = ["pending" : pending.view, "indicator" : indicator]

        var constraints = NSLayoutConstraint.constraints(withVisualFormat: "V:[indicator]-(-50)-|", options: NSLayoutConstraint.FormatOptions.alignAllCenterY, metrics: nil, views: views)
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|[indicator]|", options: NSLayoutConstraint.FormatOptions.alignAllCenterX, metrics: nil, views: views)
        pending.view.addConstraints(constraints)

        indicator.isUserInteractionEnabled = false
        indicator.startAnimating()

        showAlert(pending)
        return pending
    }
}
