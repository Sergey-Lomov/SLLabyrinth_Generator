//
//  Junction.swift
//  SLLabyrinthGenerator
//
//  Created by serhii.lomov on 06.03.2025.
//

import Foundation

/// A labyrinth element with more than two entrances.
class Junction<T: Topology>: LabyrinthElement<T> {
    let entrances: Array<T.Edge>

    init(entrances: Array<T.Edge>) {
        self.entrances = entrances
    }

    override func outcomeRestrictions(point: T.Point, field: Field<T>) -> OutcomeRestrictions {
        edgesBasedOutcomeRestrictions(point: point) {
            entrances.contains($0)
        }
    }
}

class JunctionSuperposition<T: Topology>: LabyrinthElementSuperposition<T> {
    var vaiations = T.Edge.allCases.combinations().filter { $0.count > 2 }

    override var entropy: Int {
        vaiations.count
    }

    override func applyRestriction(_ restriction: ElementRestriction<T>) {
        switch restriction {
        case .wall(let edge):
            vaiations = vaiations.filter { !$0.contains(edge) }
        case .passage(let edge):
            vaiations = vaiations.filter { $0.contains(edge) }
        }
    }

    override func waveFunctionCollapse() -> LabyrinthElement<T>? {
        guard let variation = vaiations.randomElement() else { return nil }
        return Junction(entrances: variation)
    }
}

