//
//  OneWayHolder.swift
//  SLLabyrinthIOS
//
//  Created by serhii.lomov on 20.03.2025.
//

import Foundation

/// A labyrinth element with two entrances on opposite sides, allowing movement in only one direction.
final class OneWayHolder<T: Topology>: EdgeBasedElement<T> {
    typealias Point = T.Point
    typealias Edge = T.Edge

    let oneways: [Edge]
    let walls: [Edge]

    init(passages: [Edge], oneways: [Edge] ) {
        self.oneways = oneways
        self.walls = Edge.allCases
            .filter { !passages.contains($0) && !oneways.contains($0) }

        super.init(passages: passages)
    }

    override func connectedPoints(_ point: T.Point) -> [T.Point] {
        (passages + oneways ).map {
            T.nextPoint(point: point, edge: $0)
        }
    }
}

final class OneWayHolderSuperposition<T: Topology>: TopologyBasedElementSuperposition<T>, WeightableSuperposition {
    typealias Element = StraightPath

    static var weigthCategory: String { "one_way_holder" }

    private var wallsVariations = initialState()
    private var unavailable: [Edge] = []

    static func initialState() -> [[T.Edge]] {
        T.Edge.allCases.combinations().filter { $0.count >= 1 }
    }

    override var entropy: Int {
        wallsVariations
            .map { 1 << $0.count - 1 }
            .reduce(0, +)
    }

    required init() {
        super.init()
    }

    init(variations: [[T.Edge]]) {
        self.wallsVariations = variations
        super.init()
    }

    override func copy() -> Self {
        Self.init(variations: wallsVariations)
    }

    override func applyRestriction(_ restriction: TopologyBasedElementRestriction<T>) {
        switch restriction {
        case .wall(let edge):
            wallsVariations = wallsVariations.filter { $0.contains(edge) }
        case .fieldEdge(let edge):
            wallsVariations = wallsVariations.filter { $0.contains(edge) }
            unavailable.append(edge)
        case .passage(let edge):
            wallsVariations = wallsVariations.filter { !$0.contains(edge) }
        }
    }

    override func resetRestrictions() {
        wallsVariations = Self.initialState()
    }

    override func waveFunctionCollapse() -> T.Field.Element? {
        guard let variation = wallsVariations.randomElement() else { return nil }
        let passages = T.Edge.allCases.filter { !variation.contains($0) }

        let onewayMaxMask = 1 << variation.count
        let onewayMask = Int.random(in: 1..<onewayMaxMask)
        let oneways = variation
            .elementsByMask(onewayMask)
            .filter { !unavailable.contains($0) }

        let holder = OneWayHolder<T>(passages: passages, oneways: oneways)
        return holder as? T.Field.Element
    }
}
