//
//  Topology.swift
//  SLLabyrinthGenerator
//
//  Created by serhii.lomov on 05.03.2025.
//

import Foundation

protocol Topology {
    associatedtype Edge: TopologyEdge
    associatedtype Point: Hashable

    static func nextPoint(point: Point, edge: Edge) -> Point
    static func adaptToNextPoint(_ edge: Edge) -> Edge
}

extension Topology {
    // Valid only for topologies with symmetrical edges. For other cases, it should be overridden in derived classes.
    static func adaptToNextPoint(_ edge: Edge) -> Edge {
        edge.opposite() ?? edge
    }
}

protocol TopologyEdge: Comparable & Hashable & CaseIterable {
    func opposite() -> Self?
}
