//
//  ElementsConnection.swift
//  SLLabyrinthIOS
//
//  Created by serhii.lomov on 08.04.2025.
//

import Foundation

// This structure describes an element's connections to its nearest neighbors. This data is used to calculate path graph edges.
public struct ElementsConnection<P: TopologyPoint> {
    let point: P
    let type: PathsEdgeType

    init(point: P, type: PathsEdgeType = .passage) {
        self.point = point
        self.type = type
    }
}

// This structure describes a group of element connections. This data is used to calculate path graph vertices and related edges. In rare cases, a single element may have multiple connection groups — for example, a bridge.
public struct ElementConnectionsGroup<P: TopologyPoint> {
    let vertexType: PathsVertexType
    let connections: [ElementsConnection<P>]
    let validator: (([P]) -> Bool)?

    init(
        vertexType: PathsVertexType,
        connections: [ElementsConnection<P>],
        validator: ( ([P]) -> Bool)? = nil
    ) {
        self.vertexType = vertexType
        self.connections = connections
        self.validator = validator
    }
}
