//
//  OneWayHolderSuperposition.swift
//  SLLabyrinthIOS
//
//  Created by serhii.lomov on 28.03.2025.
//

final class OneWayHolderSuperposition<T: Topology>: TopologyBasedElementSuperposition<T>, CategorizedSuperposition {
    typealias Element = StraightPath
    typealias EdgesDictionany = Dictionary<EdgeType, Set<Edge>>

    enum EdgeType {
        case income, outgoing, passage, wall, undefined
    }

    static var category: String { "one_way_holder" }

    private var allowOptionalOneways = true
    private var inconsistentRestrinctions = false
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
        guard !inconsistentRestrinctions else { return 0 }

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

    override func applyEdgesRestriction(_ restriction: TopologyBasedElementRestriction<T>, at point: Point) -> Bool {
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

        checkConsistency()
        return true
    }

    override func applySpecificRestriction(_ restriction: any ElementRestriction, at point: Point) -> Bool {
        switch restriction {
        case let oneway as OneWayRestriction<T>:
            applyOnewayRestriction(oneway)
        case is OnlyRequiredOnewaysRestriction:
            allowOptionalOneways = false
        default:
            return false
        }

        checkConsistency()
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
        inconsistentRestrinctions = false
    }

    override func waveFunctionCollapse(point: Point, field: Field) -> Field.Element? {
        var collapsedEdges = edges
        let undefined = collapsedEdges[.undefined, default: []].shuffled().toSet()

        undefined.forEach { edge in
            var types: Set<EdgeType> = [.income, .outgoing, .passage, .wall]
            let haveEntrance = Self.haveEntrance(collapsedEdges)
            let haveOneway = Self.haveOneway(collapsedEdges)

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
            collapsedEdges.insert(key: type, setValue: edge)
        }

        let passages = collapsedEdges[.passage, default: []].toArray()
        let incomes = collapsedEdges[.income, default: []].toArray()
        let outgoings = collapsedEdges[.outgoing, default: []].toArray()
        let walls = collapsedEdges[.wall, default: []].toArray()

        let holder = OneWayHolder<T>(
            passages: passages,
            incomes: incomes,
            outgoings: outgoings,
            walls: walls
        )

        return holder as? Field.Element
    }

    private func checkConsistency() {
        let defined = incomes.union(outgoings).union(passages).union(walls)
        let total = incomes.count + outgoings.count + passages.count + walls.count
        inconsistentRestrinctions = total != defined.count
    }
}
