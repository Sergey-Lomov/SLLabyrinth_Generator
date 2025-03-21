//
//  PathsGraphPatch.swift
//  SLLabyrinthIOS
//
//  Created by serhii.lomov on 12.03.2025.
//

import Foundation

struct PathsGraphPatch<T: Topology> {
    var addedVertices: [PathsGraphVertex<T>] = []
    var removedVertices: [PathsGraphVertex<T>] = []
    var addedEdges: [PathsGraphEdge<T>] = []
    var removedEdges: [PathsGraphEdge<T>] = []

    func apply(on graph: PathsGraph<T>) {
        addedVertices.forEach { graph.appendVertex($0) }
        removedVertices.forEach { graph.removeVertex($0) }
        addedEdges.forEach { graph.appendEdge($0) }
        removedEdges.forEach { graph.removeEdge($0) }
    }
}
