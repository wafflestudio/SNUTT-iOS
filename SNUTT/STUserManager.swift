//
//  STUserManager.swift
//  SNUTT
//
//  Created by Rajin on 2019. 1. 1..
//  Copyright © 2019년 WaffleStudio. All rights reserved.
//

import Foundation
import FBSDKLoginKit
import Firebase
import Swinject
import RxSwift

class STUserManager {
    var currentUser: STUser? = nil

    let networkProvider: STNetworkProvider
    let errorHandler: STErrorHandler
    let disposeBag = DisposeBag()

    init (resolver r: Resolver) {
        networkProvider = r.resolve(STNetworkProvider.self)!
        errorHandler = r.resolve(STErrorHandler.self)!
    }

    func saveData() {
        if currentUser?.fbName != nil {
            UserDefaults.standard.set(currentUser?.fbName, forKey: "UserFBName")
        }
        if currentUser?.localId != nil {
            UserDefaults.standard.set(currentUser?.localId, forKey: "UserLocalId")
        }
    }

    func loadData() {
        if let fbName = UserDefaults.standard.object(forKey: "UserFBName") as? String {
            currentUser?.fbName = fbName
        }
        if let localId = UserDefaults.standard.object(forKey: "UserLocalId") as? String {
            currentUser?.localId = localId
        }
    }

    func getUser() {
        // TODO: apiOnError or not...
        networkProvider.rx.request(STTarget.GetUser())
            .subscribe(onSuccess: { [weak self] user in
                self?.currentUser = user
                STEventCenter.sharedInstance.postNotification(event: STEvent.UserUpdated, object: nil)
            })
            .disposed(by: disposeBag)
    }

    func logOut() {
        var fcmInfos = STDefaults[.shouldDeleteFCMInfos]?.infoList ?? []
        if let token = InstanceID.instanceID().token(), let userId = STDefaults[.userId] {
            let fcmInfo = STFCMInfo(userId: userId, fcmToken: token)
            fcmInfos.append(fcmInfo)
            STDefaults[.shouldDeleteFCMInfos] = STFCMInfoList(infoList: fcmInfos)
            networkProvider.rx.request(STTarget.LogOutDevice(params: .init(user_id: userId, registration_id: token)))
                .subscribe(onSuccess: { _ in
                    let infos = STDefaults[.shouldDeleteFCMInfos]?.infoList ?? []
                    STDefaults[.shouldDeleteFCMInfos] = STFCMInfoList(infoList: infos.filter( { info in info != fcmInfo}))
                })
                .disposed(by: disposeBag)
            loadLoginPage()
        } else {
            loadLoginPage()
        }
    }

    func loadLoginPage() {
        currentUser = nil
        STDefaults[.token] = nil
        STDefaults[.userId] = nil
        #if DEBUG
        #else
        Crashlytics.sharedInstance().setUserIdentifier(nil)
        #endif
        STDefaults[.registeredFCMToken] = nil
        STDefaults[.shouldShowBadge] = false
        UIApplication.shared.delegate?.window??.rootViewController = UIStoryboard(name: "Login", bundle: Bundle.main).instantiateInitialViewController()
    }

    func loadMainPage() {
        let openController : () -> () = { [weak self] in
            guard let self = self else { return }
            if let deviceId = InstanceID.instanceID().token() {
                self.addDevice(deviceId)
            }
            let appDelegate = UIApplication.shared.delegate!
            let window = appDelegate.window!!
            let mainController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateInitialViewController()
            window.rootViewController = mainController
        }

        // TODO: this is not DI.
        let timetableManager = AppContainer.resolver.resolve(STTimetableManager.self)!
        timetableManager.getRecentTimetable()
            .subscribe(onCompleted: {
                openController()
            }, onError: { _ in
                openController()
            }).disposed(by: disposeBag)
    }

    func registerFB(id: String, token: String) {
        // TODO: test this.
        networkProvider.rx.request(STTarget.FBRegister(params: .init(fb_id: id, fb_token: token)))
            .subscribe(onSuccess: { [weak self] result in
                STDefaults[.token] = result.token
                STDefaults[.userId] = result.user_id
                self?.loadMainPage()
            })
            .disposed(by: disposeBag)
    }

    func tryFBLogin(controller: UIViewController) {

        if let accessToken = FBSDKAccessToken.current() {
            if let id = accessToken.userID,
                let token = accessToken.tokenString {
                registerFB(id: id, token: token)
            } else {
                STAlertView.showAlert(title: "로그인 실패", message: "페이스북 로그인에 실패했습니다.")
            }
        } else {
            let fbLoginManager = FBSDKLoginManager()
            fbLoginManager.logIn(withReadPermissions: ["public_profile"], from: controller, handler:{ [weak self] result, error in
                if error != nil {
                    STAlertView.showAlert(title: "로그인 실패", message: "페이스북 로그인에 실패했습니다.")
                } else {
                    if let result = result {
                        if result.isCancelled {
                            STAlertView.showAlert(title: "로그인 실패", message: "페이스북 로그인에 실패했습니다.")
                        } else {
                            let id = result.token.userID!
                            let token = result.token.tokenString!
                            self?.registerFB(id: id, token: token)
                        }
                    } else {
                        STAlertView.showAlert(title: "로그인 실패", message: "페이스북 로그인에 실패했습니다.")
                    }

                }
            })
        }
    }

    func updateDeviceIdIfNeeded() {
        guard let refreshedToken = InstanceID.instanceID().token() else {
            return
        }
        if (STDefaults[.token] != nil && STDefaults[.registeredFCMToken] != refreshedToken) {
            addDevice(refreshedToken)
        }
    }

    private func addDevice(_ deviceId: String) {
        if let userId = STDefaults[.userId] {
            let fcmInfo = STFCMInfo(userId: userId, fcmToken: deviceId)
            let infos = STDefaults[.shouldDeleteFCMInfos]?.infoList ?? []
            STDefaults[.shouldDeleteFCMInfos] = STFCMInfoList(infoList: infos.filter( { info in info != fcmInfo}))
        }

        networkProvider.rx.request(STTarget.AddDevice(id: deviceId))
            .subscribe(onSuccess: { _ in
                STDefaults[.registeredFCMToken] = deviceId
                }, onError: { _ in })
            .disposed(by: disposeBag)
    }

}
