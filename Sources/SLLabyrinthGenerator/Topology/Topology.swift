//
//  Topology.swift
//  SLLabyrinthGenerator
//
//  Created by serhii.lomov on 05.03.2025.
//

import Foundation

// Constraints on associated types were moved to a separate protocol to avoid cycles in type resolution.
public protocol Topology: UnconstrainedTopology
where Field.Point == Point,
      Superposition.Point == Point,
      Superposition.Field == Field,
      Superposition.Nested.Element == Field.Element {
}

public protocol UnconstrainedTopology {
    associatedtype Edge: TopologyEdge
    associatedtype Point: TopologyPoint
    associatedtype Field: TopologyField
    associatedtype Superposition: NodeSuperposition

    /// This method returns distance bewteen two points
    static func distance(point1: Point, point2: Point) -> Float

    /// Returns a point connected to the specified point through the specified edge.
    static func nextPoint(point: Point, edge: Edge) -> Point

    /// Returns the edge from the specified point to the specified point, or nil if the points are not connected by an edge.
    static func edge(from: Point, to: Point) -> Edge?

    /// Returns the specified edge in the context of the next point. For example, in square topology, the adapted edge for 'left' is 'right'.
    static func adaptToNextPoint(_ edge: Edge) -> Edge

    /// Scale factor required to fit the area of the specified size within the given frame size.
    static func visualScale(size: Field.Size, width: Float, height: Float) -> Float

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
    public static func edge(from: Point, to: Point) -> Edge? {
        for edge in Edge.allCases {
            if nextPoint(point: from, edge: edge) == to {
                return edge
            }
        }

        return nil
    }

    // Valid only for topologies with symmetrical edges. For other cases, it should be overridden in derived classes.
    static func adaptToNextPoint(_ edge: Edge) -> Edge {
        edge.opposite() ?? edge
    }

    static func visualScale(field: Field, width: Float, height: Float) -> Float {
        visualScale(size: field.size, width: width, height: height)
    }
}
