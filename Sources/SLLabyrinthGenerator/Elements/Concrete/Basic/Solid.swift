//
//  Untitled.swift
//  SLLabyrinthGenerator
//
//  Created by serhii.lomov on 07.03.2025.
//

import Foundation

/// A solid labyrinth element with no entrance.
final class Solid<T: Topology>: PassagesBasedElement<T> {
    override var isVisitable: Bool { false }

    init() {
        super.init(passages: [])
    }
}

final class SolidSuperposition<T: Topology>: TopologyBasedElementSuperposition<T>, CategorizedSuperposition {

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

    override func applyEdgesRestriction(_ restriction: TopologyBasedElementRestriction<T>, at point: Point) -> Bool {
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

    override func waveFunctionCollapse(point: Point, field: Field) -> Field.Element? {
        let solid = Solid<T>() as? Field.Element
        return available ? solid : nil
    }
}
