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

    let incomes: [Edge]
    let outgoings: [Edge]
    let walls: [Edge]

    init(passages: [Edge], incomes: [Edge], outgoings: [Edge] ) {
        self.incomes = incomes
        self.outgoings = outgoings

        let notWalls = passages + incomes + outgoings
        self.walls = Edge.allCases.filter { !notWalls.contains($0) }

        super.init(passages: passages)
    }

    override func connectedPoints(_ point: T.Point) -> [T.Point] {
        (passages + outgoings).map {
            T.nextPoint(point: point, edge: $0)
        }
    }

    override func outcomeRestrictions<F>(point: Point, field: F) -> OutcomeRestrictions where F : TopologyField {
        Edge.allCases
            .map { restriction(point: point, edge: $0) }
            .toDictionary()
    }

    private func restriction(point: Point, edge: Edge) -> (Point, [ElementRestriction]) {
        let next = T.nextPoint(point: point, edge: edge)
        let adapted = T.adaptToNextPoint(edge)

        var restriction: ElementRestriction? = nil
        if incomes.contains(edge) {
            restriction = OneWayRestriction<T>(edge: adapted, direction: .outgoing)
        } else if outgoings.contains(edge) {
            restriction = OneWayRestriction<T>(edge: adapted, direction: .income)
        } else if passages.contains(edge) {
            restriction = TopologyBasedElementRestriction<T>.passage(edge: adapted)
        } else {
            restriction = TopologyBasedElementRestriction<T>.wall(edge: adapted)
        }

        guard let restriction = restriction else {
            return (next, [])
        }
        let onlyRequired = OnlyRequiredOnewaysRestriction()
        return (next, [restriction, onlyRequired])
    }
}

enum OnewayDirection {
    case income, outgoing
}

final class OneWayRestriction<T: Topology>: EdgeBasedElementRestriction, IdHashable {
    typealias Edge = T.Edge

    var allowUnhandled: Bool { false }

    let id = UUID().uuidString
    let edge: Edge
    let direction: OnewayDirection

    init(edge: Edge, direction: OnewayDirection) {
        self.edge = edge
        self.direction = direction
    }
}

final class OnlyRequiredOnewaysRestriction: ElementRestriction {
    var allowUnhandled: Bool { true }
}

final class OneWayHolderSuperposition<T: Topology>: TopologyBasedElementSuperposition<T>, CategorizedSuperposition {
    typealias Element = StraightPath
    typealias EdgesDictionany = Dictionary<EdgeType, Set<Edge>>

    enum EdgeType {
        case income, outgoing, passage, wall, undefined
    }

    static var category: String { "one_way_holder" }

    private var allowOptionalOneways = true
    private var edges = initialEdges()

    private var undefined: Set<Edge> { edges[.undefined, default: []] }
    private var passages: Set<Edge> { edges[.passage, default: []] }
    private var walls: Set<Edge> { edges[.wall, default: []] }
    private var incomes: Set<Edge> { edges[.income, default: []] }
    private var outgoings: Set<Edge> { edges[.outgoing, default: []] }

    private var haveEntrance: Bool { Self.haveEntrance(edges) }
    private var haveOneway: Bool { Self.haveOneway(edges) }

    static func initialEdges() -> EdgesDictionany {
        [EdgeType.undefined: Edge.allCases.toSet()]
    }

    static func haveEntrance(_ dict: EdgesDictionany) -> Bool {
        !dict[.passage, default: []].isEmpty || !dict[.income, default: []].isEmpty
    }

    static func haveOneway(_ dict: EdgesDictionany) -> Bool {
        !dict[.outgoing, default: []].isEmpty || !dict[.income, default: []].isEmpty
    }

    override var entropy: Int {
        let edgeOptions: Int = allowOptionalOneways ? 4 : 2
        guard (haveEntrance && haveOneway) || !undefined.isEmpty else { return 0 }

        if haveEntrance {
            if haveOneway {
                // Any undefined edge may be anything
                return pow(edgeOptions, undefined.count)
            } else {
                // One of undefined edges should be income or outcome
                return pow(edgeOptions, undefined.count - 1) * 2
            }
        } else {
            if haveOneway {
                // One of undefined edges should be income or passage
                return pow(edgeOptions, undefined.count - 1) * 2
            } else {
                // One of undefined edges should be income
                return pow(edgeOptions, undefined.count - 1)
            }
        }
    }

    required init() {
        super.init()
    }

    override func copy() -> Self {
        let copy = Self.init()

        copy.edges = edges
        copy.allowOptionalOneways = allowOptionalOneways

        return copy
    }

    override func applyCommonRestriction(_ restriction: TopologyBasedElementRestriction<T>) -> Bool {
        switch restriction {
        case .wall(let edge), .fieldEdge(let edge):
            edges.remove(key: .undefined, setValue: edge)
            edges.insert(key: .wall, setValue: edge)
        case .passage(let edge):
            edges.remove(key: .undefined, setValue: edge)
            edges.insert(key: .passage, setValue: edge)
        @unknown default:
            return false
        }

        return true
    }

    override func applySpecificRestriction(_ restriction: any ElementRestriction) -> Bool {
        switch restriction {
        case let oneway as OneWayRestriction<T>:
            applyOnewayRestriction(oneway)
        case is OnlyRequiredOnewaysRestriction:
            allowOptionalOneways = false
        default:
            return false
        }

        return true
    }

    func applyOnewayRestriction(_ restriction: OneWayRestriction<T>) {
        let edge = restriction.edge
        edges.remove(key: .undefined, setValue: edge)
        switch restriction.direction {
        case .income: edges.insert(key: .income, setValue: edge)
        case .outgoing: edges.insert(key: .outgoing, setValue: edge)
        }
    }

    override func resetRestrictions() {
        edges = Self.initialEdges()
        allowOptionalOneways = true
    }

    override func waveFunctionCollapse() -> T.Field.Element? {
        var edges = edges
        let undefined = edges[.undefined, default: []].shuffled().toSet()

        undefined.forEach { edge in
            var types: Set<EdgeType> = [.income, .outgoing, .passage, .wall]
            let haveEntrance = Self.haveEntrance(edges)
            let haveOneway = Self.haveOneway(edges)

            if !haveEntrance {
                types.remove(.outgoing)
                types.remove(.wall)
            }

            if !haveOneway {
                types.remove(.passage)
                types.remove(.wall)
            }

            if !allowOptionalOneways && haveOneway {
                types.remove(.income)
                types.remove(.outgoing)
            }

            guard let type = types.randomElement() else { return }
            edges.insert(key: type, setValue: edge)
        }

        let passages = edges[.passage, default: []].toArray()
        let incomes = edges[.income, default: []].toArray()
        let outgoings = edges[.outgoing, default: []].toArray()
        let holder = OneWayHolder<T>(passages: passages, incomes: incomes, outgoings: outgoings)

        return holder as? T.Field.Element
    }
}
