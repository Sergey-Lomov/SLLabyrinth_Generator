//
//  ElementRestriction.swift
//  SLLabyrinthGenerator
//
//  Created by serhii.lomov on 05.03.2025.
//

public protocol ElementRestriction: SuperpositionRestriction {
    /// Defines a policy for superpositions that cannot handle this restriction. For example, a "lock one-way for edge" restriction may not be handled by a straight path superposition, and that is acceptable. However, if a superposition cannot handle a "should have passage on edge" restriction, it should be removed from the list of available superpositions. From a certain perspective, this flag switches the restriction into 'requirement' mode.
    var allowUnhandled: Bool { get }
}

protocol EdgeBasedElementRestriction: ElementRestriction {
    associatedtype Edge: TopologyEdge
}

enum TopologyBasedElementRestriction<T: Topology>: EdgeBasedElementRestriction, Equatable {
    typealias Edge = T.Edge

    case fieldEdge(edge: Edge)
    case wall(edge: Edge)
    case passage(edge: Edge)

    var allowUnhandled: Bool { false }
}
