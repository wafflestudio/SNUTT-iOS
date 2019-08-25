//
//  STSupportViewController.swift
//  SNUTT
//
//  Created by Rajin on 2016. 3. 21..
//  Copyright © 2016년 WaffleStudio. All rights reserved.
//

import UIKit
import RxSwift
import RxSwiftExt

class STSupportViewController: UIViewController {

    @IBOutlet weak var emailTextField: B68UIFloatLabelTextField!
    @IBOutlet weak var contentTextView: UITextView!

    let networkProvider = AppContainer.resolver.resolve(STNetworkProvider.self)!
    let errorHandler = AppContainer.resolver.resolve(STErrorHandler.self)!
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func sendButtonClicked(_ sender: AnyObject) {
        let actions = [
            UIAlertAction(title: "취소", style: .cancel, handler: nil),
            UIAlertAction(title: "전송", style: .default, handler: { [weak self] action in
                guard let self = self else { return }
                let loadingView = STAlertView.showLoading(title: "전송 중")
                self.networkProvider.rx.request(STTarget.SendFeedback(params: .init(
                    message: self.contentTextView.text,
                    email: self.emailTextField.text
                    )))
                    .do(onDispose: {
                        if !loadingView.isBeingDismissed {
                            loadingView.dismiss(animated: true)
                        }
                    })
                    .subscribe(onSuccess: { _ in
                        loadingView.dismiss(animated: true, completion: { [weak self] in
                            self?.navigationController?.popViewController(animated: true)
                        })
                    }, onError: { [weak self] error in
                        self?.errorHandler.apiOnError(error)
                    })
                    .disposed(by: self.disposeBag)
            })]

        STAlertView.showAlert(title: "전송 확인", message: "개발자에게 메세지를 전송하시겠습니까?", actions: actions)
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
