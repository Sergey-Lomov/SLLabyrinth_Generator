//
//  Topology.swift
//  SLLabyrinthGenerator
//
//  Created by serhii.lomov on 05.03.2025.
//

import Foundation

public protocol Topology {
    associatedtype Edge: TopologyEdge
    associatedtype Point: TopologyPoint

    associatedtype Field: TopologyField where Field.Point == Point, Field.Element.Restriction.Edge == Edge

    associatedtype Superposition: NodeSuperposition
    where Superposition.Point == Point,
            Superposition.Nested.Element == Field.Element,
            Superposition.Nested.Edge == Edge

    typealias ElementRestriction = Superposition.Nested.Element.Restriction

    /// This method returns a list of edges that are sufficient to connect all topology points together. For example, in a square topology, it may be a 'right'-'down' pair or any other pair consisting of one vertical and one horizontal edge.
    static func coverageFlowEdges() -> [Edge]

    /// Returns a point connected to the specified point through the specified edge.
    static func nextPoint(point: Point, edge: Edge) -> Point

    /// Returns the specified edge in the context of the next point. For example, in square topology, the adapted edge for 'left' is 'right'.
    static func adaptToNextPoint(_ edge: Edge) -> Edge

    /// Scale factor required to fit the specified field within the given frame size.
    static func visualScale(field: Field, width: Float, height: Float) -> Float

    /// Coordinates of the point's area center in Cartesian coordinate representation.
    static func visualPosition(_ point: Point) -> (Float, Float)
}

public protocol TopologyEdge: Comparable & Hashable & CaseIterable {
    func opposite() -> Self?
}

public protocol TopologyPoint: Hashable {}

extension Topology {
    // Valid only for topologies with symmetrical edges. For other cases, it should be overridden in derived classes.
    static func adaptToNextPoint(_ edge: Edge) -> Edge {
        edge.opposite() ?? edge
    }

    static func coverageFlowEdges() -> [Edge] {
        var edges: [Edge] = []
        Edge.allCases.forEach {
            if let opposite = $0.opposite() {
                if !edges.contains(opposite) {
                    edges.append($0)
                }
            } else {
                edges.append($0)
            }
        }
        return edges
    }
}
