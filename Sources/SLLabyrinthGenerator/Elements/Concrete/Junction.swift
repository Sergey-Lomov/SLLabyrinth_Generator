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

final class JunctionSuperposition<T: Topology>: TopologyBasedElementSuperposition<T>, WeightableSuperposition {
    typealias Element = Junction

    static var weigthCategory: String { "junction" }

    var variations: [[T.Edge]]

    static func initialState() -> [[T.Edge]] {
        T.Edge.allCases.combinations().filter { $0.count > 2 }
    }

    required init() {
        variations = Self.initialState()
        super.init()
    }

    init(variations: [[T.Edge]]) {
        self.variations = variations
        super.init()
    }

    override func copy() -> Self {
        Self.init(variations: variations)
    }

    override var entropy: Int {
        variations.count
    }

    override func applyRestriction(_ restriction: TopologyBasedElementRestriction<T>) {
        switch restriction {
        case .wall(let edge):
            variations = variations.filter { !$0.contains(edge) }
        case .passage(let edge):
            variations = variations.filter { $0.contains(edge) }
        }
    }

    override func resetRestrictions() {
        variations = Self.initialState()
    }

    override func waveFunctionCollapse() -> T.Field.Element? {
        guard let variation = variations.randomElement() else { return nil }
        return Junction<T>(entrances: variation) as? T.Field.Element
    }
}

