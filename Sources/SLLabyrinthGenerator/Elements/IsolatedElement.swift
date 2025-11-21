//
//  IsolatedElement.swift
//  SLLabyrinthIOS
//
//  Created by serhii.lomov on 18.11.2025.
//

import Foundation

/// An isolated labyrinth element with no entrance.
final class IsolatedElement<T: Topology>: PassagesBasedElement<T> {

    init() {
        super.init(passages: [])
    }
}

class IsolatedElementSuperposition<T: Topology>: TopologyBasedElementSuperposition<T> {

    var available = true

    override var entropy: Int {
        available ? 1 : 0
    }

    required init() {
        super.init()
    }

    required init(available: Bool) {
        super.init()
        self.available = available
    }

    override func copy() -> Self {
        Self.init(available: available)
    }

    override func applyPassagesRestriction(_ restriction: PassagesElementRestriction<T>, at point: Point) -> Bool {
        switch restriction {
        case .wall(_):
            return true
        case .passage(_):
            available = false
            return true
        }
    }

    override func preventPassagesRestriction(_ restriction: PassagesElementRestriction<T>) {
        switch restriction {
        case .wall(_):
            available = false
        case .passage(_):
            break
        }
    }

    override func resetRestrictions() {
        available = true
    }
}



