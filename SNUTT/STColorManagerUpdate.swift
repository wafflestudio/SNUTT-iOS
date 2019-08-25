//
//  STColorManagerUpdate.swift
//  SNUTT
//
//  Created by Rajin on 2017. 4. 9..
//  Copyright © 2017년 WaffleStudio. All rights reserved.
//

import Foundation

extension STColorManager {
    func updateData() {
        // TODO: not proper DI..
        let networkProvider = AppContainer.resolver.resolve(STNetworkProvider.self)!
        let _ = networkProvider.rx.request(STTarget.GetColorList())
            .subscribe(onSuccess: { [weak self] result in
                guard let self = self else { return }
                self.colorListSubject.accept(STColorList(colorList: result.colors, nameList: result.names))
                self.saveData()
                STEventCenter.sharedInstance.postNotification(event: STEvent.ColorListUpdated, object: nil)
                })
    }
}
