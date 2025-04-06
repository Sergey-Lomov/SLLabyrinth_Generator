//
//  TopologyBasedElementRestriction.swift
//  SLLabyrinthIOS
//
//  Created by serhii.lomov on 05.04.2025.
//

// TODO: Should be renamed to passages based element restriction. Also should be removed fieldEdge case. Related method in superposition also should be renamed.
enum TopologyBasedElementRestriction<T: Topology>: ElementRestriction, Equatable {
    typealias Edge = T.Edge

    case fieldEdge(edge: Edge)
    case wall(edge: Edge)
    case passage(edge: Edge)

    var allowUnhandled: Bool { false }
}
