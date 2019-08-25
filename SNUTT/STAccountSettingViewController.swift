//
//  STAccountSettingViewController.swift
//  SNUTT
//
//  Created by Rajin on 2016. 4. 3..
//  Copyright © 2016년 WaffleStudio. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import RxSwift

class STAccountSettingViewController: UITableViewController {
    let userManager = AppContainer.resolver.resolve(STUserManager.self)!
    let networkProvider = AppContainer.resolver.resolve(STNetworkProvider.self)!
    let errorHandler = AppContainer.resolver.resolve(STErrorHandler.self)!
    let disposeBag = DisposeBag()

    var isNetworking = true;
    
    enum CellType {
        case rightDetail(title: String, detail: String)
        case button(title: String)
        case redButton(title: String)
    }
    
    enum Cell {
        case showId
        case changePassword
        case attachLocalId
        case showFBId
        case detachFB
        case attachFB
        case showEmail
        case changeEmail
        case unregister

        func getCellType(currentUser: STUser?) -> CellType {
            switch (self) {
            case .showId:
                return CellType.rightDetail(title: "아이디", detail: currentUser?.localId ?? "(없음)")
            case .changePassword:
                return CellType.button(title: "비밀번호 변경")
            case .attachLocalId:
                return .button(title: "아이디 비번 추가")
            case .showFBId:
                return .rightDetail(title: "페이스북 이름", detail: currentUser?.fbName ?? "(없음)")
            case .detachFB:
                return .button(title: "페이스북 연동 취소")
            case .attachFB:
                return .button(title: "페이스북 연동")
            case .showEmail:
                return .rightDetail(title: "이메일", detail: currentUser?.email ?? "(없음)")
            case .changeEmail:
                return .button(title: "이메일 변경")
            case .unregister:
                return .redButton(title: "회원탈퇴")
            }
        }
    }
    
    var cellList : [[Cell]] = []
    var fbSection : Int = 0
    var emailSection : Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        STEventCenter.sharedInstance.addObserver(self, selector: #selector(STAccountSettingViewController.userUpdated), event: STEvent.UserUpdated, object: nil)
        
        refreshCellList()
        getUser()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    @objc func userUpdated() {
        isNetworking = false
        refreshCellList()
        self.tableView.reloadData()
    }
    
    func getUser() {
        isNetworking = true;
        userManager.getUser()
    }
    
    func refreshCellList() {
        cellList = []
        
        if (userManager.currentUser?.localId == nil) {
            cellList.append([Cell.attachLocalId])
        } else {
            cellList.append([Cell.showId, Cell.changePassword])
        }
        
        fbSection = cellList.count
        if (userManager.currentUser?.fbName == nil) {
            cellList.append([Cell.attachFB])
        } else {
            cellList.append([Cell.showFBId, Cell.detachFB])
        }
        
        emailSection = cellList.count
        cellList.append([Cell.showEmail, Cell.changeEmail])
        
        cellList.append([Cell.unregister])
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return cellList.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellList[section].count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellType = cellList[indexPath.section][indexPath.row].getCellType(currentUser: userManager.currentUser)
        switch cellType {
        case .rightDetail(let title, let detail):
            let cell = tableView.dequeueReusableCell(withIdentifier: "RightDetailCell", for: indexPath)
            cell.textLabel?.text = title
            cell.detailTextLabel?.text = detail
            return cell
        case .button(let title):
            let cell = tableView.dequeueReusableCell(withIdentifier: "ButtonCell", for: indexPath)
            cell.textLabel?.text = title
            cell.accessoryType = .disclosureIndicator
            return cell
        case .redButton(let title):
            let cell = tableView.dequeueReusableCell(withIdentifier: "RedButtonCell",for: indexPath) as! STRedButtonTableViewCell
            cell.buttonLabel.text = title
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if isNetworking {
            return
        }
        let cell = cellList[indexPath.section][indexPath.row]
        let networkProvider = self.networkProvider
        let disposeBag = self.disposeBag
        switch (cell) {
        case .attachFB:
            let registerFB : (String, String) -> () = { [weak self] id, token in
                guard let self = self else { return }
                self.networkProvider.rx.request(STTarget.AddFacebook(params: .init(fb_id: id, fb_token: token)))
                    .subscribe(onSuccess: { [weak self] _ in
                        guard let self = self else { return }
                        self.userManager.getUser()
                        self.refreshCellList()
                        self.tableView.reloadSections(IndexSet(integer: self.fbSection), with: .automatic)
                        }, onError: self.errorHandler.apiOnError
                    ).disposed(by: self.disposeBag)
            }
            
            if let accessToken = FBSDKAccessToken.current(),
                let id = accessToken.userID,
                let token = accessToken.tokenString {
                registerFB(id, token)
            } else {
                let fbLoginManager = FBSDKLoginManager()
                fbLoginManager.logIn(withReadPermissions: ["public_profile"], from: self, handler:{result, error in
                    if error != nil {
                        STAlertView.showAlert(title: "페북 연동 실패", message: "페이스북 연동에 실패했습니다.")
                        return
                    }
                    guard let result = result else {
                        STAlertView.showAlert(title: "페북 연동 실패", message: "페이스북 연동에 실패했습니다.")
                        return
                    }
                    if result.isCancelled {
                        STAlertView.showAlert(title: "페북 연동 실패", message: "페이스북 연동에 실패했습니다.")
                    } else if let id = result.token.userID,
                        let token = result.token.tokenString {
                        registerFB(id, token)
                    } else {
                        STAlertView.showAlert(title: "페북 연동 실패", message: "페이스북 연동에 실패했습니다.")
                    }
                })
            }
            return
        case .attachLocalId:
            performSegue(withIdentifier: "AddLocalID", sender: nil)
            return
        case .changeEmail:
            STAlertView.showAlert(title: "이메일 변경", message: "새로운 이메일 주소를 입력해주세요", configAlert: { alert in
                alert.addTextField(configurationHandler: { textfield in
                    textfield.placeholder = "새로운 이메일 주소"
                    textfield.keyboardType = .emailAddress
                })
                alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
                alert.addAction(UIAlertAction(title: "이메일 변경", style: .default, handler: { _ in
                    if let email = alert.textFields?.first?.text {
                        if (STUtil.validateEmail(email)) {
                            networkProvider.rx.request(STTarget.EditUser(params: .init(email: email)))
                                .subscribe(onSuccess: { [weak self] _ in
                                    guard let self = self else { return }
                                    self.userManager.currentUser?.email = email
                                    self.tableView.reloadSections(IndexSet(integer: self.emailSection), with: .automatic)
                                    }, onError: { [weak self] error in
                                        self?.errorHandler.apiOnError(error)
                                        STAlertView.showAlert(title: "이메일 변경", message: "이메일 변경에 실패했습니다.")
                                })
                                .disposed(by: disposeBag)
                            return
                        }
                    }
                    STAlertView.showAlert(title: "이메일 변경", message: "올바른 이메일 주소를 입력해 주세요.")
                }))
            })
            return
        case .changePassword:
            STAlertView.showAlert(title: "비밀번호 변경", message: "새로운 비밀번호를 입력해주세요", configAlert: { alert in
                alert.addTextField(configurationHandler: { textfield in
                    textfield.placeholder = "현재 비밀번호"
                    textfield.isSecureTextEntry = true
                })
                alert.addTextField(configurationHandler: { textfield in
                    textfield.placeholder = "새로운 비밀번호"
                    textfield.isSecureTextEntry = true
                })
                alert.addTextField(configurationHandler: { textfield in
                    textfield.placeholder = "새로운 비밀번호 확인"
                    textfield.isSecureTextEntry = true
                })
                alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
                alert.addAction(UIAlertAction(title: "비번 변경", style: .default, handler: { _ in
                    let curPass = alert.textFields?[0].text ?? ""
                    let newPass = alert.textFields?[1].text ?? ""
                    let newPass2 = alert.textFields?[2].text ?? ""
                    if (newPass != newPass2) {
                        STAlertView.showAlert(title: "비밀번호 변경", message: "비밀번호와 비밀번호 확인란이 다릅니다.")
                        return
                    } else if (!STUtil.validatePassword(newPass)) {
                        var message : String = ""
                        if (newPass.characters.count > 20  || newPass.characters.count < 6) {
                            message = "비밀번호는 6자 이상, 20자 이하여야 합니다."
                        } else {
                            message = "비밀번호는 최소 숫자 1개와 영문자 1개를 포함해야 합니다."
                        }
                        STAlertView.showAlert(title: "비밀번호 변경", message: message)
                        return
                    }
                    networkProvider.rx.request(STTarget.ChangePassword(params: .init(old_password: curPass, new_password: newPass)))
                        .subscribe(onSuccess: { result in
                            STDefaults[.token] = result.token
                        }, onError: { [weak self] error in
                            self?.errorHandler.apiOnError(error)
                        })
                }))
            })
            return
        case .detachFB:
            if userManager.currentUser?.localId == nil {
                STAlertView.showAlert(title: "페이스북 연동 끊기", message: "현재 로그인 수단이 페이스북 밖에 없기 때문에, 페이스북 연동을 끊을 수 없습니다.")
                return
            }
            let detachAction = UIAlertAction(title: "페이스북 연동 끊기", style: .destructive, handler: { [weak self] _ in
                guard let self = self else { return }
                self.networkProvider.rx.request(STTarget.DetachFacebook())
                    .subscribe(onSuccess: { [weak self] _ in
                        guard let self = self else { return }
                        self.userManager.currentUser?.fbName = nil
                        self.refreshCellList()
                        self.tableView.reloadSections(IndexSet(integer: self.fbSection), with: .automatic)
                        }, onError: self.errorHandler.apiOnError
                    ).disposed(by: self.disposeBag)
            })
            let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
            STAlertView.showAlert(title: "페이스북 연동 끊기", message: "페이스북 연동을 끊겠습니까?", actions: [cancelAction, detachAction])
            return
        case .unregister:
            let unregisterAction = UIAlertAction(title: "회원탈퇴", style: .destructive, handler: { [weak self] _ in
                guard let self = self else { return }
                self.networkProvider.rx.request(STTarget.DeleteUser())
                    .subscribe(onSuccess: { [weak self] _ in
                        self?.userManager.loadLoginPage()
                        }, onError: self.errorHandler.apiOnError
                    ).disposed(by: self.disposeBag)
            })
            let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
            STAlertView.showAlert(title: "회원탈퇴", message: "SNUTT 회원 탈퇴를 하겠습니까?", actions: [cancelAction, unregisterAction])
            return
        default:
            return
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
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
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
