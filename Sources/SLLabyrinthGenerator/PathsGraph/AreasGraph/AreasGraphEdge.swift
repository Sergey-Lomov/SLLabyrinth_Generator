//
//  AreasGraphEdge.swift
//  SLLabyrinthIOS
//
//  Created by serhii.lomov on 15.03.2025.
//

import Foundation

struct AreasGraphEdge<T: Topology>: GraphEdge {
    typealias Vertex = PathsGraphArea<T>

    let id = UIDProvider.next()
    let pathsEdge: PathsGraphEdge<T>
    let from: PathsGraphArea<T>
    let to: PathsGraphArea<T>

    func isReversed(_ edge: AreasGraphEdge<T>) -> Bool {
        from == edge.to && to == edge.from && pathsEdge.isReversed(edge.pathsEdge)
    }

    func reversed() -> Self {
        Self(pathsEdge: pathsEdge.reversed(), from: to, to: from)
    }
}
