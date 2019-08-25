//
//  CoreAssembly.swift
//  SNUTT
//
//  Created by Rajin on 2018. 8. 12..
//  Copyright © 2018년 WaffleStudio. All rights reserved.
//

import Foundation
import Swinject

class CoreAssembly : Assembly {
    func assemble(container: Container) {
        container.register(STTimetableManager.self) { r in
            STTimetableManager()
        }.inObjectScope(.container)
        container.register(STSettingManager.self) { r in
            STSettingManager()
            }.inObjectScope(.container)
        container.register(STCourseBookListManager.self) { r in
            STCourseBookListManager(resolver: r)
        }.inObjectScope(.container)
        container.register(STTagManager.self) { r in STTagManager(resolver: r) }
            .inObjectScope(.container)
        container.register(STColorManager.self) { r in STColorManager() }
            .inObjectScope(.container)
        container.register(STNetworkProvider.self) { r in STNetworkProvider() }
            .inObjectScope(.container)
        container.register(STErrorHandler.self) { r in STErrorHandler() }
            .inObjectScope(.container)
        container.register(STUserManager.self) { r in STUserManager(resolver: r) }
            .inObjectScope(.container)
    }
}
