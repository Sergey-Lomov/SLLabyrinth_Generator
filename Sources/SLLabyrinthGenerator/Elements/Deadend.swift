//
//  Deadend.swift
//  SLLabyrinthGenerator
//
//  Created by serhii.lomov on 05.03.2025.
//

import Foundation

/// A labyrinth element with only one entrance.
class Deadend<T: Topology>: LabyrinthElement<T> {
    let entrance: T.Edge

    init(entrance: T.Edge) {
        self.entrance = entrance
    }

    override func outcomeRestrictions(point: T.Point, field: Field<T>) -> OutcomeRestrictions {
        edgesBasedOutcomeRestrictions(point: point) {
            $0 == entrance
        }
    }
}

class DeadendSuperposition<T: Topology>: LabyrinthElementSuperposition<T> {
    var entrances = Set(T.Edge.allCases)

    override var entropy: Int {
        entrances.count
    }

    override func applyRestriction(_ restriction: ElementRestriction<T>) {
        switch restriction {
        case .wall(let edge):
            entrances = entrances.filter { $0 != edge }
        case .passage(let edge):
            entrances = entrances.filter { $0 == edge }
        }
    }

    override func waveFunctionCollapse() -> LabyrinthElement<T>? {
        guard let target = entrances.randomElement() else { return nil }
        return Deadend(entrance: target)
    }
}
