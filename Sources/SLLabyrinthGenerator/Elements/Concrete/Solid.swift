//
//  Untitled.swift
//  SLLabyrinthGenerator
//
//  Created by serhii.lomov on 07.03.2025.
//

import Foundation

/// A solid labyrinth element with no entrance.
class Solid<T: Topology>: EdgeBasedElement<T> {
    override var isVisitable: Bool { false }

    init() {
        super.init(passages: [])
    }
}

final class SolidSuperposition<T: Topology>: TopologyBasedElementSuperposition<T>, WeightableSuperposition {
    typealias Element = Solid

    static var weigthCategory: String { "solid" }

    var available = true

    override var entropy: Int {
        available ? 1 : 0
    }

    required init() {
        super.init()
    }

    init(available: Bool) {
        super.init()
        self.available = available
    }

    override func copy() -> Self {
        Self.init(available: available)
    }

    override func applyRestriction(_ restriction: TopologyBasedElementRestriction<T>) {
        switch restriction {
        case .passage(_): available = false
        default: break
        }
    }

    override func resetRestrictions() {
        available = true
    }

    override func waveFunctionCollapse() -> T.Field.Element? {
        let solid = Solid<T>() as? T.Field.Element
        return available ? solid : nil
    }
}
