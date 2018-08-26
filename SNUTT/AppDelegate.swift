//
//  AppDelegate.swift
//  SNUTT
//
//  Created by 김진형 on 2015. 7. 2..
//  Copyright (c) 2015년 WaffleStudio. All rights reserved.
//

import UIKit
import UserNotifications
import Fabric
import Crashlytics
import SwiftyJSON
import FBSDKCoreKit
import Firebase
import Alamofire


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        #if DEBUG
        #else
            Fabric.with([Crashlytics.self])
        #endif

        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)

        let path = Bundle.main.path(forResource: "config", ofType: "plist")!
        let configAllDict = NSDictionary(contentsOfFile: path)!

        #if DEBUG
            let infoName = "GoogleService-Info-Dev"
        #elseif PRODUCTION
            let infoName = "GoogleService-Info-Production"
        #else
            let infoName = "GoogleService-Info-Dev"
        #endif

        let filePath = Bundle.main.path(forResource: infoName, ofType: "plist")
        let options = FirebaseOptions(contentsOfFile: filePath!)
        FirebaseApp.configure(options: options!)

        setColors()
        
        // open main or login depending on the token
        if STDefaults[.token] != nil {
            self.window?.rootViewController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateInitialViewController()
        } else {
            self.window?.rootViewController = UIStoryboard(name: "Login", bundle: Bundle.main).instantiateInitialViewController()
        }
        
        if STDefaults[.token] != nil {
            STMainTabBarController.controller?.setNotiBadge(STDefaults[.shouldShowBadge])
            STNetworking.getNotificationCount({ cnt in
                STMainTabBarController.controller?.setNotiBadge(cnt != 0)
                
                }, failure: { 
                    return
            })
        }
        

        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self

            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()

        if (InstanceID.instanceID().token() != nil) {
            STUser.updateDeviceIdIfNeeded()
            connectToFcm()
        }

        // For STColorList UserDefaults
        NSKeyedArchiver.setClassName("STColorList", for: STColorList.self)
        NSKeyedUnarchiver.setClass(STColorList.self, forClassName: "STColorList")
        // For STFCMInfo UserDefaults
        NSKeyedArchiver.setClassName("STFCMInfo", for: STFCMInfo.self)
        NSKeyedUnarchiver.setClass(STFCMInfo.self, forClassName: "STFCMInfo")

        
        var fcmInfos = STDefaults[.shouldDeleteFCMInfos]?.infoList ?? []
        for fcmInfo in fcmInfos {
            STNetworking.logOut(userId: fcmInfo.userId, fcmToken: fcmInfo.fcmToken, done: {
                let infos = STDefaults[.shouldDeleteFCMInfos]?.infoList ?? []
                STDefaults[.shouldDeleteFCMInfos] = STFCMInfoList(infoList: infos.filter( { info in info != fcmInfo}))
            }, failure: nil)
        }

        return true
    }
    
    func setColors() {
        UINavigationBar.appearance().tintColor = UIColor.black
        UITabBar.appearance().tintColor = UIColor.black
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.

        receivedNotification()

        // Print message ID.
        #if DEBUG
            print("Message ID: \(userInfo["gcm.message_id"]!)")
            print("%@", userInfo)
        #endif

        completionHandler(UIBackgroundFetchResult.newData)
    }

    func receivedNotification() {
        STMainTabBarController.controller?.notificationController?.refreshList()
        STMainTabBarController.controller?.setNotiBadge(true)
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func messaging(_ messaging: Messaging, didRefreshRegistrationToken fcmToken: String) {
        STUser.updateDeviceIdIfNeeded()
        connectToFcm()
    }

    func connectToFcm() {
        Messaging.messaging().connect { (error) in
            #if DEBUG
            if (error != nil) {
                print("Unable to connect with FCM. \(error)")
            } else {
                print("Connected to FCM.")
            }
            #endif
        }
    }
    func applicationDidEnterBackground(_ application: UIApplication) {
        Messaging.messaging().disconnect()
        print("Disconnected from FCM.")
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        let fbHandled = FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
        return fbHandled
    }
}

@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {

    // Receive displayed notifications for iOS 10 devices.

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        receivedNotification()
    }
}

extension AppDelegate : MessagingDelegate {
    // Receive data message on iOS 10 devices.
    func applicationReceivedRemoteMessage(remoteMessage: MessagingRemoteMessage) {
        #if DEBUG
        print("%@", remoteMessage.appData)
        #endif
        receivedNotification()
    }
}
