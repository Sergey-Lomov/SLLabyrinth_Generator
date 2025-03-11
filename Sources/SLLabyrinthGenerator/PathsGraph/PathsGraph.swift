//
//  PathsGraph.swift
//  SLLabyrinthGenerator
//
//  Created by serhii.lomov on 09.03.2025.
//

final class PathsGraph<T: Topology> {
    typealias Vertex = PathsGraphVertex<T>
    typealias Edge = PathsGraphEdge<T>

    var vertices: Set<Vertex> = []
    var edges: Set<Edge> = []
    var fromMap: Dictionary<Vertex, [Edge]> = [:]
    var toMap: Dictionary<Vertex, [Edge]> = [:]

    /// Embeds vertices that have only two edges into a merged edge. For example, the graph V1--E1-->V2--E2-->V3 will be compacted to V1--E3-->V3, where E3 consists of E1's points plus V2's point plus E2's points.
    func compactizePaths() {
        for vertex in Array(vertices) {
            guard let outEdges = fromMap[vertex], outEdges.count == 2,
                  let inEdges = toMap[vertex], inEdges.count == 2 else {
                // If a vertex has more or fewer than 2 incoming or outgoing edges, it should not be optimized
                continue
            }

            let sourceToLeft = outEdges[0]
            let sourceToRight = outEdges[1]
            let left = sourceToLeft.to
            let right = sourceToRight.to
            let leftToSource = inEdges.first { $0.isReversed(sourceToLeft) }
            let rightToSource = inEdges.first { $0.isReversed(sourceToRight) }
            guard let leftToSource = leftToSource, let rightToSource = rightToSource else {
                // If the incoming and outgoing edges are not symmetric, a vertex should not be optimized
                continue
            }

            let leftToRightPoints = left.point + leftToSource.intermediatePoints + vertex.point + sourceToRight.intermediatePoints + right.point
            let rightToLeftPoints = right.point + rightToSource.intermediatePoints + vertex.point + sourceToLeft.intermediatePoints + left.point
            let leftToRight = Edge(points: leftToRightPoints, from: left, to: right)
            let rightToLeft = Edge(points: rightToLeftPoints, from: right, to: left)

            removeVertex(vertex)
            appendEdge(leftToRight)
            appendEdge(rightToLeft)
        }
    }

    func appendEdge(points: [T.Point]) {
        guard let from = points.first, let to = points.last, from != to else { return }
        let fromVertex = vertices.first { $0.point == from } ?? Vertex(point: from)
        let toVertex = vertices.first { $0.point == to } ?? Vertex(point: to)

        let edge = Edge(points: points, from: fromVertex, to: toVertex)
        appendEdge(edge)
    }

    private func appendEdge(_ edge: PathsGraphEdge<T>) {
        edges.insert(edge)
        vertices.insert(edge.from)
        vertices.insert(edge.to)
        fromMap.append(key: edge.from, arrayValue: edge)
        toMap.append(key: edge.to, arrayValue: edge)
    }

    private func removeEdge(_ edge: PathsGraphEdge<T>) {
        edges.remove(edge)
        fromMap.remove(key: edge.from, arrayValue: edge)
        toMap.remove(key: edge.to, arrayValue: edge)
        removeIfUnused(edge.from)
        removeIfUnused(edge.to)
    }

    private func removeIfUnused(_ vertex: PathsGraphVertex<T>) {
        let emptyFrom = fromMap[vertex]?.isEmpty ?? true
        let emptyTo = toMap[vertex]?.isEmpty ?? true
        if emptyTo && emptyFrom { removeVertex(vertex) }
    }

    private func removeVertex(_ vertex: PathsGraphVertex<T>) {
        vertices.remove(vertex)
        fromMap[vertex]?.forEach { removeEdge($0) }
        toMap[vertex]?.forEach { removeEdge($0) }
        fromMap[vertex] = nil
        toMap[vertex] = nil
    }
}
