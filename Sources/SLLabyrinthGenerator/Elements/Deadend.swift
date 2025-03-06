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
}

class DeadendSuperposition<T: Topology>: LabyrinthElementSuperposition<T> {
    var entrances = Set(T.Edge.allCases)

    override var entropy: Int {
        entrances.count
    }

    override func applyRestriction(_ restriction: ElementRestriction<T>) {
        switch restriction {
        case .WallRestriction(let edge):
            entrances = entrances.filter { $0 != edge }
        case .PassageRestriction(let edge):
            entrances = entrances.filter { $0 == edge }
        }
    }

    override func waveFunctionCollapse() -> LabyrinthElement<T>? {
        guard let target = entrances.randomElement() else { return nil }
        return Deadend(entrance: target)
    }
}
