//
//  Topology.swift
//  SLLabyrinthGenerator
//
//  Created by serhii.lomov on 05.03.2025.
//

import Foundation

protocol Topology {
    associatedtype Edge: TopologyEdge
    associatedtype Point

    func nextPoint(point: Point, edge: Edge)
}

protocol TopologyEdge: Comparable & Hashable & CaseIterable {
    func opposite() -> Self?
}
