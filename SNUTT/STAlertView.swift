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
    
    static private func createAlert(title title: String, message: String) -> UIAlertController {
        return UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
    }
    
    static private func showAlert(alert: UIAlertController) {
        UIApplication.sharedApplication().keyWindow!.rootViewController!.presentViewController(alert, animated: true, completion: nil)
    }
    
    static func showAlert(title title: String, message: String) {
        let alert = STAlertView.createAlert(title: title, message: message)
        alert.addAction(UIAlertAction(title: "확인", style: UIAlertActionStyle.Default, handler: nil))
        STAlertView.showAlert(alert)
    }
    
    static func showAlert(title title: String, message: String, actions: [UIAlertAction]) {
        let alert = STAlertView.createAlert(title: title, message: message)
        for it in actions {
            alert.addAction(it)
        }
        STAlertView.showAlert(alert)
    }
}