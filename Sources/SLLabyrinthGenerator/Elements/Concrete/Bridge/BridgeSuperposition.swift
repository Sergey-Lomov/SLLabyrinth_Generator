//
//  BridgeSuperposition.swift
//  SLLabyrinthIOS
//
//  Created by serhii.lomov on 08.04.2025.
//

import Foundation

final class BridgeSuperposition<T: Topology>: TopologyBasedElementSuperposition<T>, CategorizedSuperposition {

    static var category: String { "bridge" }

    var pathsVariations:Set<[[Edge]]>

    static func initialVariations() -> Set<[[Edge]]> {
        let id = String(reflecting: Self.self) + "_initPaths"
        return GlobalCache.getValue(id: id) { computeInitialVariations() }
    }

    static func computeInitialVariations() -> Set<[[Edge]]>{
        let pairs = T.Edge.allCases.pairs()
            .filter { $0.opposite() == $1}
            .map { [$0, $1] }

        return pairs.combinations()
            .filter { $0.count > 1 }
            .toSet()
    }

    required init() {
        pathsVariations = Self.initialVariations()
    }

    override var entropy: Int {
        pathsVariations.count
    }

    override func copy() -> Self {
        let copy = Self.init()
        copy.pathsVariations = pathsVariations
        return copy
    }

    override func applyPassagesRestriction(_ restriction: PassagesElementRestriction<T>, at point: Point) -> Bool {
        switch restriction {
        case .wall(let edge):
            pathsVariations = pathsVariations.filter { paths in
                paths.allSatisfy { !$0.contains(edge) }
            }
        case .passage(let edge):
            pathsVariations = pathsVariations.filter { paths in
                paths.contains { $0.contains(edge) }
            }
        }

        return true
    }

    override func applyConnectionRestriction(_ restriction: ConnectionPreventRestriction<T>, at point: Point) -> Bool {
        if let edge = T.edge(from: point, to: restriction.target) {
            pathsVariations = pathsVariations.filter { paths in
                paths.allSatisfy { !$0.contains(edge) }
            }
        }
        return true
    }

    override func resetRestrictions() {
        super.resetRestrictions()
        pathsVariations = Self.initialVariations()
    }

    override func waveFunctionCollapse(point: Point, field: Field) -> Field.Element? {
        guard let paths = pathsVariations.randomElement() else { return nil }
        let bridge = Bridge<T>(paths: paths)
        return bridge as? Field.Element
    }
}
