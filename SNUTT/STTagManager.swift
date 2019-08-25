//
//  STTagManager.swift
//  SNUTT
//
//  Created by Rajin on 2016. 3. 4..
//  Copyright © 2016년 WaffleStudio. All rights reserved.
//

import Foundation
import Alamofire
import Swinject
import RxSwift

class STTagManager {

    let timetableManager: STTimetableManager
    let networkProvider: STNetworkProvider
    let errorHandler: STErrorHandler
    let disposeBag = DisposeBag()

    init(resolver r: Resolver) {
        timetableManager = r.resolve(STTimetableManager.self)!
        networkProvider = r.resolve(STNetworkProvider.self)!
        errorHandler = r.resolve(STErrorHandler.self)!
        timetableManager.rx.currentTimetable
            .map { $0?.quarter }
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] _ in
                self?.loadData()
            }).disposed(by: disposeBag)
    }
    
    var tagList : STTagList!
    
    func loadData() {
        guard let quarter = timetableManager.currentTimetable?.quarter else {
            return
        }
        if let data = try? Data(contentsOf: getFileUrl(quarter: quarter)),
            let tagList = try? PropertyListDecoder().decode(STTagList.self, from: data) {
            self.tagList = tagList
        } else {
            self.tagList = STTagList(quarter: quarter, tagList: [], updatedTime: 0)
        }
        self.updateTagList()
    }
    
    func saveData(_ quarter: STQuarter) {
        guard let data = try? PropertyListEncoder().encode(tagList) else { return }
        do {
            try data.write(to: getFileUrl(quarter: quarter))
        } catch let error {
            print(error.localizedDescription)
        }
    }

    private func getFileUrl(quarter: STQuarter) -> URL {
        var url = getDocumentsDirectory()
        url.appendPathComponent("tagList\(quarter.shortString()).archive")
        return url
    }

    func getTagListWithQuarter(_ quarter: STQuarter, updatedTime : Int64) {
        networkProvider.rx.request(STTarget.GetTagList(year: quarter.year, semester: quarter.semester))
            .map { result -> STTagList in
                var tags: [STTag] = []
                tags += result.classification?.map {
                    return STTag(type: .Classification, text: $0)
                } ?? []
                tags += result.department?.map {
                    return STTag(type: .Department, text: $0)
                    } ?? []
                tags += result.academic_year?.map {
                    return STTag(type: .AcademicYear, text: $0)
                    } ?? []
                tags += result.credit?.map {
                    return STTag(type: .Credit, text: $0)
                    } ?? []
                tags += result.instructor?.map {
                    return STTag(type: .Instructor, text: $0)
                    } ?? []
                tags += result.category?.map {
                    return STTag(type: .Category, text: $0)
                    } ?? []
                let updatedTime = result.updated_at
                return STTagList(quarter: quarter, tagList: tags, updatedTime: updatedTime)
            }.subscribe(onSuccess: { [weak self] tagList in
                guard let self = self else { return }
                if self.tagList.quarter == quarter {
                    self.tagList = tagList
                    self.saveData(quarter)
                }
            }, onError: { [weak self] err in
                self?.errorHandler.apiOnError(err)
                self?.tagList = STTagList(quarter: quarter, tagList: [], updatedTime: 0)
            })
            .disposed(by: disposeBag)
    }


    
    func updateTagList() {
        networkProvider.rx.request(STTarget.GetTagListUpdateTime(year: tagList.quarter.year, semester: tagList.quarter.semester))
            .map { $0.updated_at}
            .subscribe(onSuccess: { [weak self] updatedTime in
                guard let self = self else { return }
                if self.tagList.updatedTime != updatedTime {
                    self.getTagListWithQuarter(self.tagList.quarter, updatedTime: updatedTime)
                }
                }, onError: errorHandler.apiOnError)
            .disposed(by: disposeBag)
    }

}
