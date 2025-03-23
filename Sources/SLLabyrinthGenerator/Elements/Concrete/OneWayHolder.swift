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
            let counter = OneWayRestriction<T>(edge: edge, type: .locked)
            restrictions.append(key: point, arrayValue: counter)
        }

        return restrictions
    }
}

final class OneWayRestriction<T: Topology>: ElementRestriction, IdHashable {
    typealias Edge = T.Edge

    enum RestrictionType {
        case locked, required
    }

    let id = UUID().uuidString
    let edge: Edge
    let type: RestrictionType

    init(edge: Edge, type: RestrictionType) {
        self.edge = edge
        self.type = type
    }
}

final class OneWayHolderSuperposition<T: Topology>: TopologyBasedElementSuperposition<T>, CategorizedSuperposition {
    typealias Element = StraightPath

    static var category: String { "one_way_holder" }

    private var wallsVariations = initialState()
    private var onewaysUnavailable: Set<Edge> = []
    private var onewaysForced: Set<Edge> = []

    static func initialState() -> [[T.Edge]] {
        T.Edge.allCases.combinations().filter { $0.count >= 1 }
    }

    override var entropy: Int {
        guard onewaysForced.intersection(onewaysUnavailable).isEmpty else { return 0 }
        return wallsVariations
            .map {
                if onewaysForced.isEmpty {
                    return 1 << $0.count -  1
                } else {
                    return 1 << $0.count - onewaysForced.count
                }
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
            appendOnewaysUnavailable(edge)
        case .passage(let edge):
            wallsVariations = wallsVariations.filter { !$0.contains(edge) }
        }
    }

    override func applySpecificRestriction(_ restriction: any ElementRestriction) {
        guard let oneWay = restriction as? OneWayRestriction<T> else { return }
        switch oneWay.type {
        case .locked:
            appendOnewaysUnavailable(oneWay.edge)
        case .required:
            onewaysForced.insert(oneWay.edge)
            wallsVariations = wallsVariations.filter { $0.contains(oneWay.edge) }
        }
    }

    override func resetRestrictions() {
        wallsVariations = Self.initialState()
    }

    override func waveFunctionCollapse() -> T.Field.Element? {
        guard let walls = wallsVariations.randomElement() else { return nil }
        let passages = T.Edge.allCases.filter { !walls.contains($0) }
        let optionalOneways = walls.filter {
            !onewaysUnavailable.contains($0) && !onewaysForced.contains($0)
        }

        guard !optionalOneways.isEmpty || !onewaysForced.isEmpty else {
            return nil
        }

        var selectedOptional: [Edge] = []
        if !optionalOneways.isEmpty {
            let onewayMaxMask = 1 << optionalOneways.count
            let onewayMask = Int.random(in: 1..<onewayMaxMask)
            selectedOptional = optionalOneways.elementsByMask(onewayMask)
        }

        let oneways = selectedOptional + onewaysForced
        let holder = OneWayHolder<T>(passages: passages, oneways: oneways)
        return holder as? T.Field.Element
    }

    private func appendOnewaysUnavailable(_ edge: Edge) {
        onewaysUnavailable.insert(edge)
        wallsVariations = wallsVariations.filter { !onewaysUnavailable.contains($0) }
    }
}
