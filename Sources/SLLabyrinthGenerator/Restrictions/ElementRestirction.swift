//
//  ElementRestriction.swift
//  SLLabyrinthGenerator
//
//  Created by serhii.lomov on 05.03.2025.
//

public protocol ElementRestriction {
    associatedtype Edge: TopologyEdge
}

enum TopologyBasedElementRestriction<T: Topology>: ElementRestriction {
    typealias Edge = T.Edge

    case wall(edge: Edge)
    case passage(edge: Edge)
}
