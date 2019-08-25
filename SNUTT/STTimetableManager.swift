//
//  STTimetableManager.swift
//  SNUTT
//
//  Created by Rajin on 2016. 1. 6..
//  Copyright © 2016년 WaffleStudio. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class STTimetableManager : ReactiveCompatible {

    // TODO: eager loading. (with alpha in actual timetable)

    let disposeBag = DisposeBag()
    let networkProvider = AppContainer.resolver.resolve(STNetworkProvider.self)!
    let errorHandler = AppContainer.resolver.resolve(STErrorHandler.self)!
    let currentTimetableSubject = BehaviorRelay<STTimetable?>(value: nil)
    let currentTemporaryLectureSubject = BehaviorRelay<STLecture?>(value: nil)

    init() {
        self.loadData()
        if let timetableId = currentTimetable?.id {
            networkProvider.rx.request(STTarget.GetTimetable(id: timetableId))
                .subscribe(onSuccess: { [weak self] timetable in
                    self?.currentTimetable = timetable
                    }, onError: { [weak self] e in
                        self?.errorHandler.apiOnError(e)
                })
                .disposed(by: disposeBag)
        } else {
            currentTimetable = nil
        }
    }
    
    private(set) var currentTimetable : STTimetable? {
        get {
            return currentTimetableSubject.value
        }
        set {
            let oldValue = currentTimetable
            currentTimetableSubject.accept(newValue)
            if oldValue?.id != newValue?.id {
                currentTemporaryLectureSubject.accept(nil)
            }
            saveData()
        }
    }

    private(set) var currentTemporaryLecture: STLecture? {
        get {
            return currentTemporaryLectureSubject.value
        }
        set {
            currentTemporaryLectureSubject.accept(newValue)
        }
    }

    func loadData() {
        currentTimetable = STDefaults[.currentTimetable]
    }
    
    func saveData() {
        STDefaults[.currentTimetable] = currentTimetable
        STDefaults.synchronize()
    }
    
    func addCustomLecture(_ lecture : STLecture) -> Completable {
        guard let currentTimetableId = currentTimetable?.id else {
            return Completable.error("Current Timetable does not exist")
        }
        let params = STTarget.AddCustomLecture.Params(
            classification: lecture.classification,
            department: lecture.department,
            academic_year: lecture.academicYear,
            course_number: lecture.courseNumber,
            lecture_number: lecture.lectureNumber,
            course_title: lecture.title,
            credit: lecture.credit,
            instructor: lecture.instructor,
            quota: lecture.quota,
            remark: lecture.remark,
            category: lecture.category,
            class_time_json: lecture.classList,
            color: lecture.color,
            colorIndex: lecture.colorIndex
        )
        return networkProvider.rx.request(STTarget.AddCustomLecture(params: params, timetableId: currentTimetableId))
            .do(onSuccess: { [weak self] newTimetable in
                self?.currentTimetable = newTimetable
                }, onError: { [weak self] err in
                    self?.errorHandler.apiOnError(err)
            }).asCompletable()
    }
    
    func addLecture(_ lectureId : String) -> Completable {
        guard let currentTimetableId = currentTimetable?.id else {
            return Completable.error("Current timetable does not exist")
        }
        return networkProvider.rx.request(STTarget.AddLecture(timetableId: currentTimetableId, lectureId: lectureId))
            .do(onSuccess: { [weak self] newTimetable in
                self?.currentTimetable = newTimetable
                }, onError: { [weak self] err in
                    self?.errorHandler.apiOnError(err)
            }).asCompletable()
    }
    
    func updateLecture(_ oldLecture : STLecture, newLecture : STLecture) -> Completable {
        guard let timetableId = currentTimetable?.id,
            let lectureId = oldLecture.id,
            let index = currentTimetable?.lectureList.index(where: { lec in
                return lec.id == newLecture.id
            }) else {
                return Completable.error("lecture or timetable doesn't exist")
        }

        let updateLectureParams = STTarget.UpdateLecture.Params(
            classification: difference(oldLecture.classification, to: newLecture.classification),
            department: difference(oldLecture.department, to: newLecture.department),
            academic_year: difference(oldLecture.academicYear, to: newLecture.academicYear),
            course_number: difference(oldLecture.courseNumber, to: newLecture.courseNumber),
            lecture_number: difference(oldLecture.lectureNumber, to: newLecture.lectureNumber),
            course_title: difference(oldLecture.title, to: newLecture.title),
            credit: difference(oldLecture.credit, to: newLecture.credit),
            instructor: difference(oldLecture.instructor, to: newLecture.instructor),
            quota: difference(oldLecture.quota, to: newLecture.quota),
            remark: difference(oldLecture.remark, to: newLecture.remark),
            category: difference(oldLecture.category, to: newLecture.category),
            class_time_json: difference(oldLecture.classList, to: newLecture.classList),
            color: difference(oldLecture.color, to: newLecture.color),
            colorIndex: difference(oldLecture.colorIndex, to: newLecture.colorIndex)
        )

        return networkProvider.rx.request(STTarget.UpdateLecture(params: updateLectureParams, timetableId: timetableId, lectureId: lectureId))
            .do(onSuccess: { [weak self] newTimetable in
                self?.currentTimetable = newTimetable
                }
            )
            .asCompletable()
    }

    private func difference<T: Equatable>(_ a: T, to b: T) -> T? {
        if (a == b) {
            return nil
        } else {
            return b
        }
    }
    
    func deleteLectureAtIndex(_ index: Int) -> Completable {
        guard let currentTimetableId = currentTimetable?.id else {
            return Completable.error("Current timetable does not exist.")
        }
        guard let lectureId = currentTimetable?.lectureList[index].id else {
            return Completable.error("lecture does not have id")
        }
        return networkProvider.rx.request(STTarget.DeleteLecture(timetableId: currentTimetableId, lectureId: lectureId))
            .do(onSuccess: { [weak self] newTimetable in
                self?.currentTimetable = newTimetable
                }, onError: { [weak self] err in
                    self?.errorHandler.apiOnError(err)
                    })
            .asCompletable()
    }

    func updateTitle(title: String) -> Completable {
        guard let currentTimetableId = currentTimetable?.id else {
            return Completable.error("Current timetable does not exist.")
        }
        return self.networkProvider.rx.request(STTarget.UpdateTimetable(params: .init(title: title), id: currentTimetableId))
            .do(onSuccess: { [weak self] _ in
                self?.currentTimetable?.title = title
                }, onError: self.errorHandler.apiOnError
            ).asCompletable()
    }

    func getTimetable(id: String) -> Completable {
        return networkProvider.rx.request(STTarget.GetTimetable(id: id))
            .do(onSuccess: { [weak self] timetable in
                self?.currentTimetable = timetable
                }, onError: errorHandler.apiOnError)
        .asCompletable()
    }

    func getRecentTimetable() -> Completable {
        return networkProvider.rx.request(STTarget.GetRecentTimetable())
            .do(onSuccess: { [weak self] timetable in
                self?.currentTimetable = timetable
                }, onError: { [weak self] error in
                    self?.errorHandler.apiOnError(error)
            }).asCompletable()
    }
    
    //FIXME: Refactoring Needed
    func resetLecture(_ lectureId: String) -> Completable {
        guard let currentTimetableId = currentTimetable?.id else {
            return Completable.error("Current timetable does not exist")
        }
        return networkProvider.rx.request(STTarget.ResetLecture(timetableId: currentTimetableId, lectureId: lectureId))
            .do(onSuccess: {[weak self] newTimetable in
                self?.currentTimetable?.lectureList = newTimetable.lectureList
                }, onError: errorHandler.apiOnError
            ).asCompletable()
    }
    
    func setTemporaryLecture(_ lecture :STLecture?) {
        // TODO: check timetable Id?
        currentTemporaryLecture = lecture
    }
}

extension Reactive where Base == STTimetableManager {
    var currentTimetable : Observable<STTimetable?> {
        return base.currentTimetableSubject.asObservable()
    }
    var currentTemporaryLecture: Observable<STLecture?> {
        return base.currentTemporaryLectureSubject.asObservable()
    }
}
