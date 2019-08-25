//
//  STAddLocalIDViewController.swift
//  SNUTT
//
//  Created by Rajin on 2017. 2. 9..
//  Copyright © 2017년 WaffleStudio. All rights reserved.
//

import UIKit
import SafariServices
import RxSwift

class STAddLocalIDViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var idTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordCheckTextField: UITextField!

    var textFields : [UITextField] {
        get {
            return [idTextField, passwordTextField, passwordCheckTextField]
        }
    }

    @IBOutlet weak var addButton: STViewButton!
    @IBOutlet weak var termView: UIView!

    let networkProvider = AppContainer.resolver.resolve(STNetworkProvider.self)!
    let errorHandler = AppContainer.resolver.resolve(STErrorHandler.self)!
    let userManager = AppContainer.resolver.resolve(STUserManager.self)!
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        //textField
        let textFieldList = self.textFields
        for textField in textFieldList {
            textField.delegate = self
        }

        addButton.buttonPressAction = {
            self.saveButtonClicked()
        }

        let termTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.termLabelClicked))
        termView.addGestureRecognizer(termTapRecognizer)
    }
    
    func saveButtonClicked() {
        self.view.endEditing(true)
        let title = "아이디 추가 실패"
        var failure = false
        var message = ""
        
        let id = idTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        let passwordCheck = passwordCheckTextField.text ?? ""
        
        if passwordCheck != password {
            failure = true
            message = "비밀번호 확인란과 비밀번호가 다릅니다."
        } else if !STUtil.validateId(id) {
            if (id.characters.count > 32 || id.characters.count < 4) {
                message = "아이디는 4자 이상, 32자 이하여야합니다."
            } else {
                message = "아이디는 영문자와 숫자로만 이루어져 있어야 합니다."
            }
            failure = true
        } else if !STUtil.validatePassword(password) {
            if (password.characters.count > 20  || password.characters.count < 6) {
                message = "비밀번호는 6자 이상, 20자 이하여야 합니다."
            } else {
                message = "비밀번호는 최소 숫자 1개와 영문자 1개를 포함해야 합니다."
            }
            failure = true
        }

        if failure {
            STAlertView.showAlert(title: title, message: message)
        } else {
            networkProvider.rx.request(STTarget.AddLocalId(params: .init(id: id, password: password)))
                .subscribe(onSuccess: { [weak self] result in
                    STDefaults[.token] = result.token
                    self?.userManager.getUser()
                    self?.navigationController?.popViewController(animated: true)
                }, onError: errorHandler.apiOnError)
                .disposed(by: disposeBag)
        }
    }

    @objc func termLabelClicked() {
        self.view.endEditing(true)
        let url = STConfig.sharedInstance.baseURL + "/terms_of_service"
        let svc = SFSafariViewController(url: URL(string: url)!)
        self.present(svc, animated: true, completion: nil)
    }

    // MARK: TextFieldDelegate

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let loginTextField = textField as? STLoginTextField else {
            return false
        }
        let textFieldList = self.textFields

        if let index = textFieldList.index(of: loginTextField) {
            if index == textFieldList.count - 1 {
                textField.resignFirstResponder()
                saveButtonClicked()
                return true
            }
            textFieldList[index + 1].becomeFirstResponder()
            return false
        }
        return false
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
