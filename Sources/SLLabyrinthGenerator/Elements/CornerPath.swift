//
//  CornerPath.swift
//  SLLabyrinthGenerator
//
//  Created by serhii.lomov on 05.03.2025.
//

import Foundation

/// A labyrinth element with two entrances on non-opposite sides.
class CornerPath<T: Topology>: LabyrinthElement<T> {
    let path: (T.Edge, T.Edge)

    init(path: (T.Edge, T.Edge)) {
        self.path = path
    }

    override func outcomeRestrictions(point: T.Point, field: Field<T>) -> OutcomeRestrictions {
        edgesBasedOutcomeRestrictions(point: point) {
            path.0 == $0 || path.1 == $0
        }
    }
}

class CornerPathSuperposition<T: Topology>: LabyrinthElementSuperposition<T> {
    var paths = T.Edge.allCases.pairs().removeOppositePairs()

    override var entropy: Int {
        paths.count
    }

    override func applyRestriction(_ restriction: ElementRestriction<T>) {
        switch restriction {
        case .wall(let edge):
            paths = paths.filter { $0 != edge && $1 != edge }
        case .passage(let edge):
            paths = paths.filter { $0 == edge || $1 == edge }
        }
    }

    override func waveFunctionCollapse() -> LabyrinthElement<T>? {
        guard let path = paths.randomElement() else { return nil }
        return CornerPath(path: path)
    }
}
