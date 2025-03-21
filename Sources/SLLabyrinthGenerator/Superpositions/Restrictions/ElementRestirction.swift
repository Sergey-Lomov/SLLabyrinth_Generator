//
//  ElementRestriction.swift
//  SLLabyrinthGenerator
//
//  Created by serhii.lomov on 05.03.2025.
//

public protocol ElementRestriction: SuperpositionRestriction {
    associatedtype Edge: TopologyEdge
}

enum TopologyBasedElementRestriction<T: Topology>: ElementRestriction, Equatable {
    typealias Edge = T.Edge

    case fieldEdge(edge: Edge)
    case wall(edge: Edge)
    case passage(edge: Edge)
}
