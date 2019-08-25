//
//  STApiOnError.swift
//  SNUTT
//
//  Created by Rajin on 2018. 12. 30..
//  Copyright © 2018년 WaffleStudio. All rights reserved.
//

import Foundation

class STErrorHandler {
    func apiOnError(_ error: Error) {
        switch error {
        case STHttpError.networkError:
            showNetworkError()
        case let STHttpError.errorCode(errorCode):
            switch errorCode {
            case STErrorCode.NO_USER_TOKEN, STErrorCode.WRONG_USER_TOKEN:
                // TODO: not proper DI but works...
                AppContainer.resolver.resolve(STUserManager.self)!.logOut()
            default:
                STAlertView.showAlert(title: errorCode.errorTitle, message: errorCode.errorMessage)
            }
        default:
            break
        }
    }

    private func showNetworkError() {
        let alert = UIAlertController(title: "Network Error", message: "네트워크 환경이 원활하지 않습니다.", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "확인", style: UIAlertAction.Style.default, handler: nil))
        UIApplication.shared.keyWindow!.rootViewController!.present(alert, animated: true, completion: nil)
    }
}
