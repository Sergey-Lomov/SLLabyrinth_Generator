//
//  Deadend.swift
//  SLLabyrinthGenerator
//
//  Created by serhii.lomov on 05.03.2025.
//

import Foundation

/// A labyrinth element with only one entrance.
class Deadend<T: Topology>: EdgeBasedElement<T> {
    init(entrance: T.Edge) {
        super.init(passages: [entrance])
    }
}

final class DeadendSuperposition<T: Topology>: TopologyBasedElementSuperposition<T> {
    var entrances = Set(T.Edge.allCases)

    override var entropy: Int {
        entrances.count
    }

    required init() {
        super.init()
    }

    init(entrances: Set<T.Edge>) {
        super.init()
        self.entrances = entrances
    }

    override func copy() -> Self {
        Self.init(entrances: entrances)
    }

    override func applyRestriction(_ restriction: TopologyBasedElementRestriction<T>) {
        switch restriction {
        case .wall(let edge):
            entrances = entrances.filter { $0 != edge }
        case .passage(let edge):
            entrances = entrances.filter { $0 == edge }
        }
    }

    override func resetRestrictions() {
        entrances = Set(T.Edge.allCases)
    }

    override func waveFunctionCollapse() -> T.Field.Element? {
        guard let target = entrances.randomElement() else { return nil }
        return Deadend<T>(entrance: target) as? T.Field.Element
    }
}
