//
//  AppContainer.swift
//  SNUTT
//
//  Created by Rajin on 2018. 8. 12..
//  Copyright © 2018년 WaffleStudio. All rights reserved.
//

import Foundation
import Swinject

class AppContainer {
    static let resolver : Resolver = createResolver()

    static private func createResolver() -> Resolver {
        let assembler = Assembler([
            CoreAssembly()
            ])
        return assembler.resolver
    }
}
