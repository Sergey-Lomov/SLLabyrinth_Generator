//
//  TeleporterRestriction.swift
//  SLLabyrinthIOS
//
//  Created by serhii.lomov on 29.03.2025.
//

import Foundation

final class TeleporterRestriction<T: Topology>: ElementRestriction, IdHashable {

    let id = UUID().uuidString
    let target: T.Point?
    let types: Set<TeleporterType>

    var allowUnhandled: Bool { false }

    init(target: T.Point?, types: Set<TeleporterType>) {
        self.target = target
        self.types = types
    }
}

final class TeleporterCoefficientRestriction: ElementRestriction, IdHashable {
    let id = UUID().uuidString
    let coefficient: Int

    var allowUnhandled: Bool { true }

    init(coefficient: Int) {
        self.coefficient = coefficient
    }
}
