//
//  STMainTabBarController.swift
//  SNUTT
//
//  Created by Rajin on 2016. 9. 18..
//  Copyright © 2016년 WaffleStudio. All rights reserved.
//

import UIKit
import RxSwift

class STMainTabBarController: UITabBarController {

    static weak var controller : STMainTabBarController? = nil

    weak var notificationController : STNotificationTableViewController? = nil
    let timetableManager = AppContainer.resolver.resolve(STTimetableManager.self)!
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        STMainTabBarController.controller = self
        for item in self.tabBar.items! {
            item.image = item.image!.withRenderingMode(.alwaysOriginal)
        }
        setNotiBadge(STDefaults[.shouldShowBadge])
        if timetableManager.currentTimetable == nil {
            timetableManager.getRecentTimetable()
                .subscribe(onError: { _ in })
                .disposed(by: disposeBag)
        }
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        
    }
    
    func setNotiBadge(_ shouldShowBadge: Bool) {
        let notiBarItem = self.tabBar.items![2]
        if (shouldShowBadge) {
            notiBarItem.image = #imageLiteral(resourceName: "tabAlarmNotiOff").withRenderingMode(.alwaysOriginal)
            notiBarItem.selectedImage = #imageLiteral(resourceName: "tabAlarmNotiOn").withRenderingMode(.alwaysOriginal)
        } else {
            notiBarItem.image = #imageLiteral(resourceName: "tabAlarmOff").withRenderingMode(.alwaysOriginal)
            notiBarItem.selectedImage = #imageLiteral(resourceName: "tabAlarmOn").withRenderingMode(.alwaysOriginal)
        }
        STDefaults[.shouldShowBadge] = shouldShowBadge
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
