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

final class SolidSuperposition<T: Topology>: TopologyBasedElementSuperposition<T>, CategorizedSuperposition {
    typealias Element = Solid

    static var category: String { "solid" }

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

    override func applyCommonRestriction(_ restriction: TopologyBasedElementRestriction<T>) -> Bool {
        switch restriction {
        case .fieldEdge(_), .wall(_):
            return true
        case .passage(_):
            available = false
            return true
        @unknown default:
            return false
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
