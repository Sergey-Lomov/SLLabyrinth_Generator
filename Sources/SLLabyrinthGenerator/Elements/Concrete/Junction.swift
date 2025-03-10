//
//  Junction.swift
//  SLLabyrinthGenerator
//
//  Created by serhii.lomov on 06.03.2025.
//

import Foundation

/// A labyrinth element with more than two entrances.
class Junction<T: Topology>: EdgeBasedElement<T> {
    init(entrances: [T.Edge]) {
        super.init(passages: entrances)
    }
}

class JunctionSuperposition<T: Topology>: LabyrinthElementSuperposition<T> {
    var vaiations = T.Edge.allCases.combinations().filter { $0.count > 2 }

    override var entropy: Int {
        vaiations.count
    }

    override func applyRestriction(_ restriction: TopologyBasedElementRestriction<T>) {
        switch restriction {
        case .wall(let edge):
            vaiations = vaiations.filter { !$0.contains(edge) }
        case .passage(let edge):
            vaiations = vaiations.filter { $0.contains(edge) }
        }
    }

    override func waveFunctionCollapse() -> TopologyBasedLabyrinthElement<T>? {
        guard let variation = vaiations.randomElement() else { return nil }
        return Junction(entrances: variation)
    }
}

