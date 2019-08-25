//
//  STColorPickerTableViewController.swift
//  SNUTT
//
//  Created by Rajin on 2016. 3. 2..
//  Copyright © 2016년 WaffleStudio. All rights reserved.
//

import UIKit
import ChameleonFramework

class STColorPickerTableViewController: UITableViewController {

    let colorManager = AppContainer.resolver.resolve(STColorManager.self)!

    var customColorIndex = 1
    var color : STColor!
    var colorIndex: Int = 1
    var selectedColorIndex = 1
    var doneBlock : (Int, STColor?) -> () = { _,_  in }
    var colorList : STColorList!
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UINib(nibName: "STColorTableViewCell", bundle: Bundle.main),
                           forCellReuseIdentifier: "STColorTableViewCell")
        tableView.register(UINib(nibName: "STSingleColorTableViewCell", bundle: Bundle.main),
                           forCellReuseIdentifier: "STSingleColorTableViewCell")

        colorListUpdated()

        STEventCenter.sharedInstance.addObserver(self, selector: #selector(colorListUpdated), event: STEvent.ColorListUpdated, object: nil)
    }

    deinit {
        STEventCenter.sharedInstance.removeObserver(self)
    }
    
    override func willMove(toParent parent: UIViewController?) {
        if parent == nil {
            let retColorIndex = selectedColorIndex == customColorIndex ? 0 : selectedColorIndex + 1
            let retColor = selectedColorIndex == customColorIndex ? color : nil
            doneBlock(retColorIndex, retColor)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @objc func colorListUpdated() {
        colorList = colorManager.colorList
        customColorIndex = colorList.colorList.count
        if colorIndex == 0 {
            selectedColorIndex = customColorIndex
        } else if colorIndex > colorList.colorList.count {
            selectedColorIndex = customColorIndex
        } else {
            selectedColorIndex = colorIndex - 1
        }
        tableView.reloadData()
        self.tableView.selectRow(at: IndexPath(row: selectedColorIndex, section: 0), animated: false, scrollPosition: .none)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        if selectedColorIndex == customColorIndex {
            return 2
        } else {
            return 1
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return colorList.colorList.count + 1
        case 1:
            return 2
        default:
            return 0
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "STColorTableViewCell", for: indexPath) as! STColorTableViewCell
            if indexPath.row == colorList.colorList.count {
                cell.color = STColor()
                cell.colorLabel.text = "직접 지정하기"
                cell.setBorder(false)
            } else {
                cell.color = colorList.colorList[indexPath.row]
                cell.colorLabel.text = colorList.nameList[indexPath.row]
                cell.setBorder(true)
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "STSingleColorTableViewCell", for: indexPath) as! STSingleColorTableViewCell
            cell.accessoryType = .disclosureIndicator
            if indexPath.row == 0 {
                cell.label.text = "배경색"
                cell.colorView.backgroundColor = color.bgColor
            } else {
                cell.label.text = "글씨색"
                cell.colorView.backgroundColor = color.fgColor
            }
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 0 {
            if indexPath.row != selectedColorIndex {
                self.tableView.deselectRow(at: IndexPath(row: selectedColorIndex, section: 0), animated: true)
                
                let wasSelectedColorIndex = selectedColorIndex
                selectedColorIndex = indexPath.row
                
                if wasSelectedColorIndex == customColorIndex {
                    self.tableView.deleteSections(IndexSet(integer: 1), with: .top)
                }
                if selectedColorIndex != customColorIndex {
                    color = colorList.colorList[indexPath.row]
                } else {
                    color = STColor()
                    self.tableView.insertSections(IndexSet(integer: 1), with: .top)
                }
            }
        } else if indexPath.section == 1 {
            self.tableView.deselectRow(at: indexPath, animated: true)
            let pickerViewController = self.storyboard?.instantiateViewController(withIdentifier: "STCustomColorPickerViewController") as! STCustomColorPickerViewController
            if indexPath.row == 0 {
                pickerViewController.color = self.color.bgColor
                pickerViewController.doneBlock = { color in
                    self.color.bg = color.toHexString()
                    self.tableView.reloadSections(IndexSet(integer: 1), with: .none)
                }
            } else {
                pickerViewController.color = self.color.fgColor
                pickerViewController.doneBlock = { color in
                    self.color.fg = color.toHexString()
                    self.tableView.reloadSections(IndexSet(integer: 1), with: .none)
                }
            }
            
            self.navigationController?.pushViewController(pickerViewController, animated: true)
        }
    }

    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            self.tableView.selectRow(at: indexPath, animated: false, scrollPosition: UITableView.ScrollPosition.none)
        }
    }
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
