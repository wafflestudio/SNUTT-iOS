//
//  STTimetableTabViewController.swift
//  SNUTT
//
//  Created by Rajin on 2016. 1. 7..
//  Copyright © 2016년 WaffleStudio. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

class STTimetableTabViewController: UIViewController {
    
    lazy var timetableView2 = STTimetableView()
    var lectureListController : STMyLectureListController!
    let timetableManager = AppContainer.resolver.resolve(STTimetableManager.self)!
    let settingManager = AppContainer.resolver.resolve(STSettingManager.self)!
    let colorManager = AppContainer.resolver.resolve(STColorManager.self)!
    let networkProvider = AppContainer.resolver.resolve(STNetworkProvider.self)!
    let errorHandler = AppContainer.resolver.resolve(STErrorHandler.self)!

    var colorPickerInfoRelay = BehaviorRelay<(id: String, colorIndex: Int)?>(value: nil)

    let disposeBag = DisposeBag()

    enum State {
        case timetable
        case lectureList
    }
    
    var state : State = .timetable
    var isInAnimation : Bool = false

    @IBOutlet weak var containerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        containerView.addSubview(timetableView2)
        timetableView2.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        Observable.combineLatest(
            timetableManager.rx.currentTimetable,
            colorPickerInfoRelay.asObservable(),
            resultSelector: {(timetable, info) -> [CompactLecture] in
                timetable?.lectureList.map { lecture -> CompactLecture in
                    if lecture.id == info?.id {
                        var compactLecture = lecture.toCompactLecture()
                        compactLecture.colorIndex = info?.colorIndex ?? 0
                        return compactLecture
                    } else {
                        return lecture.toCompactLecture()
                    }
                    } ?? []
        }).subscribe(onNext: { [weak self] compactLectureList in
            self?.timetableView2.setCompactLectureList(compactLectureList)
        }).disposed(by: disposeBag)

        settingManager.rx.fitMode
            .subscribe(onNext: {[weak self] fitMode in
                self?.timetableView2.setFitMode(fitMode)
            }).disposed(by: disposeBag)

        colorManager.rx.colorList
            .subscribe(onNext: {[weak self] colorList in
                self?.timetableView2.setColorList(colorList)
            }).disposed(by: disposeBag)

        // Add tap recognizer to title in NavigationBar
        let titleView = UILabel()
        titleView.font = UIFont(name: "HelveticaNeue-Medium", size: 17)
        titleView.frame = CGRect(origin:CGPoint.zero, size:CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude))
        titleView.textAlignment = .center
        self.navigationItem.titleView = titleView
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(STTimetableTabViewController.titleWasTapped))
        titleView.isUserInteractionEnabled = true
        titleView.addGestureRecognizer(recognizer)
        
        self.navigationItem.leftBarButtonItem!.target = self
        self.navigationItem.leftBarButtonItem!.action = #selector(self.switchView)
        
        lectureListController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "MyLectureListController") as! STMyLectureListController
        lectureListController.timetableTabViewController = self
        lectureListController.view.frame = self.containerView.frame
        self.containerView.addSubview(lectureListController.view)
        lectureListController.view.isHidden = true

        timetableManager.rx.currentTimetable.subscribe(onNext: { [weak self] timetable in
            guard let self = self else { return }
            let titleView = (self.navigationItem.titleView as! UILabel)
            let attribute = [NSAttributedString.Key.foregroundColor : UIColor.darkGray,
                             NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15)]
            let totalCreditStr = NSAttributedString(string: " \(timetable?.totalCredit ?? 0)학점", attributes: attribute)
            let mutableStr = NSMutableAttributedString()
            mutableStr.append(NSAttributedString(string: timetable?.title ?? ""))
            mutableStr.append(totalCreditStr)
            titleView.attributedText = mutableStr
            titleView.invalidateIntrinsicContentSize()
        }).disposed(by: disposeBag)

        timetableView2.clickedLectureRelay.asObservable()
            .subscribe(onNext: { [weak self] lectureId in
                guard let self = self else { return }
                guard let lecture = self.timetableManager.currentTimetable?.lectureList.first(where: { $0.id == lectureId}) else {
                    return
                }
                self.lectureViewTapped(lecture)
            })
            .disposed(by: disposeBag)

        timetableView2.longPressedLectureRelay.asObservable()
            .subscribe(onNext: { [weak self] lectureId in
                guard let self = self else { return }
                guard let lecture = self.timetableManager.currentTimetable?.lectureList.first(where: { $0.id == lectureId}) else {
                    return
                }
                self.lectureViewLongPressed(lecture)
            })
            .disposed(by: disposeBag)
    }

    deinit {
        STEventCenter.sharedInstance.removeObserver(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func switchView() {

        if (isInAnimation) {
            return
        }
        isInAnimation = true
        var oldView, newView : UIView!
        switch state {
        case .timetable:
            oldView = timetableView2
            newView = lectureListController.view
        case .lectureList:
            oldView = lectureListController.view
            newView = timetableView2
        }

        UIView.animate(withDuration: 0.65, animations: {
            switch self.state {
            case .lectureList:
                self.navigationItem.leftBarButtonItem!.image = #imageLiteral(resourceName: "topbarListview")
            case .timetable:
                self.navigationItem.leftBarButtonItem!.image = #imageLiteral(resourceName: "group2Copy")
            }
        })

        UIView.transition(with: containerView, duration: 0.65, options: .transitionFlipFromRight, animations: {
            oldView.isHidden = true
            newView.isHidden = false
        }, completion: { finished in
            self.state = (self.state == .timetable) ? .lectureList : .timetable
            self.isInAnimation = false
        })
    }
    
    @objc func titleWasTapped() {
        guard let currentTimetable = timetableManager.currentTimetable else {
            return
        }
        guard let timetableId = currentTimetable.id else {
            return
        }
        
        STAlertView.showAlert(title: "시간표 이름 변경", message: "새로운 시간표 이름을 입력해주세요", configAlert: { alert in
            alert.addTextField(configurationHandler: { textfield in
                textfield.placeholder = "새로운 시간표 이름"
            })
            alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "이름 변경", style: .default, handler: { [weak self] _ in
                guard let self = self else { return }
                if let timetableName = alert.textFields?.first?.text {
                    let timetableManager = self.timetableManager
                    timetableManager.updateTitle(title: timetableName)
                        .subscribe()
                        .disposed(by: self.disposeBag)
                }
            }))
        })
    }

    func lectureViewTapped(_ lecture: STLecture) {
        let detailController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "LectureDetailTableViewController") as! STLectureDetailTableViewController
        detailController.lecture = lecture
        self.navigationController?.pushViewController(detailController, animated: true)

    }

    func lectureViewLongPressed (_ lecture: STLecture) {
        guard let lectureId = lecture.id else { return }
        let oldColorIndex = lecture.colorIndex
        let oldLecture = lecture
        STColorActionSheetPicker.showWithColor(oldColorIndex ?? 0, doneBlock: { [weak self] selectedColorIndex in
            guard let self = self else { return }
            self.colorPickerInfoRelay.accept((lectureId, selectedColorIndex))
            var newLecture = lecture
            newLecture.colorIndex = selectedColorIndex
            newLecture.color = nil
            self.timetableManager.updateLecture(oldLecture, newLecture: newLecture)
                .subscribe(onCompleted: { [weak self] in
                    self?.colorPickerInfoRelay.accept(nil)
                    }, onError: { [weak self] err in
                        self?.errorHandler.apiOnError(err)
                        self?.colorPickerInfoRelay.accept(nil)
                }).disposed(by: self.disposeBag)

            }, cancelBlock: { [weak self] in
                self?.colorPickerInfoRelay.accept(nil)
            }, selectedBlock: { [weak self] colorIndex in
                self?.colorPickerInfoRelay.accept((lectureId, colorIndex))
            }, origin: self)
    }
}
