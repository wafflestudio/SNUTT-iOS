//
//  STCustomColorPickerViewController.swift
//  SNUTT
//
//  Created by Rajin on 2016. 3. 3..
//  Copyright © 2016년 WaffleStudio. All rights reserved.
//

import UIKit
import Color_Picker_for_iOS

class STCustomColorPickerViewController: UIViewController {

    @IBOutlet weak var colorPickerView: HRColorPickerView!
    
    var doneBlock : (UIColor) -> () = { _ in }
    var color : UIColor!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        colorPickerView.color = self.color
        // Do any additional setup after loading the view.
    }

    override func willMove(toParent parent: UIViewController?) {
        if parent == nil {
            doneBlock(colorPickerView.color)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
