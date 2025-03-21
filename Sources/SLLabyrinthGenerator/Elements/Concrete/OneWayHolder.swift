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

    override func outcomeRestrictions<F>(point: EdgeBasedElement<T>.Point, field: F) -> EdgeBasedElement<T>.OutcomeRestrictions where F : TopologyField {
        var restrictions = super.outcomeRestrictions(point: point, field: field)

        oneways.forEach {
            let point = T.nextPoint(point: point, edge: $0)
            let edge = T.adaptToNextPoint($0)
            let counter = CounterOneWayRestriction<T>(edge: edge)
            restrictions.append(key: point, arrayValue: counter)
        }

        return restrictions
    }
}

final class CounterOneWayRestriction<T: Topology>: ElementRestriction, IdHashable {
    typealias Edge = T.Edge

    let id = UUID().uuidString
    let edge: Edge

    init(edge: Edge) {
        self.edge = edge
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
            .map { variation in
                let filtered = variation.filter { !unavailable.contains($0) }
                return filtered.isEmpty ? 0 : 1 << filtered.count - 1
            }
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

    override func applyCommonRestriction(_ restriction: TopologyBasedElementRestriction<T>) {
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

    override func applySpecificRestriction(_ restriction: any ElementRestriction) {
        if let counter = restriction as? CounterOneWayRestriction<T> {
            unavailable.append(counter.edge)
        }
    }

    override func resetRestrictions() {
        wallsVariations = Self.initialState()
    }

    override func waveFunctionCollapse() -> T.Field.Element? {
        guard let variation = wallsVariations.randomElement() else { return nil }
        let passages = T.Edge.allCases.filter { !variation.contains($0) }
        let filtered = variation.filter { !unavailable.contains($0) }

        guard !filtered.isEmpty else { return nil }

        let onewayMaxMask = 1 << filtered.count
        let onewayMask = Int.random(in: 1..<onewayMaxMask)
        let oneways = filtered.elementsByMask(onewayMask)
        let holder = OneWayHolder<T>(passages: passages, oneways: oneways)

        return holder as? T.Field.Element
    }
}
