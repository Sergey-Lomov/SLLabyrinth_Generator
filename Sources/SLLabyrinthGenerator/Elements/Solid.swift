//
//  Untitled.swift
//  SLLabyrinthGenerator
//
//  Created by serhii.lomov on 07.03.2025.
//

import Foundation

/// A solid labyrinth element with no entrance.
class Solid<T: Topology>: LabyrinthElement<T> {
    override func outcomeRestrictions(point: T.Point, field: Field<T>) -> OutcomeRestrictions {
        edgesBasedOutcomeRestrictions(point: point) { _ in
            false
        }
    }
}

class SolidSuperposition<T: Topology>: LabyrinthElementSuperposition<T> {
    var available = true

    override var entropy: Int {
        available ? 1 : 0
    }

    override func applyRestriction(_ restriction: ElementRestriction<T>) {
        switch restriction {
        case .passage(_): available = false
        default: break
        }
    }

    override func waveFunctionCollapse() -> LabyrinthElement<T>? {
        available ? Solid() : nil
    }
}
