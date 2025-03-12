//
//  PathsGraph.swift
//  SLLabyrinthGenerator
//
//  Created by serhii.lomov on 09.03.2025.
//
//

final class PathsGraph<T: Topology> {
    typealias Vertex = PathsGraphVertex<T>
    typealias Edge = PathsGraphEdge<T>
    typealias Area = PathsGraphArea<T>

    var vertices: Set<Vertex> = []
    var edges: Set<Edge> = []
    var fromMap: Dictionary<Vertex, [Edge]> = [:]
    var toMap: Dictionary<Vertex, [Edge]> = [:]

    var points: Set<T.Point> {
        if edges.isEmpty {
            return Set(vertices.map { $0.point })
        } else {
            return Set(edges.flatMap { $0.points })
        }
    }

    /// Embeds vertices that have only two edges into a merged edge. For example, the graph V1--E1-->V2--E2-->V3 will be compacted to V1--E3-->V3, where E3 consists of E1's points plus V2's point plus E2's points.
    func compactizePaths() {
        for vertex in Array(vertices) {
            _ = compactize(vertex: vertex)
        }
    }

    func compactize(vertex: Vertex) -> PathsGraphPatch<T> {
        var patch = PathsGraphPatch<T>()

        guard let outEdges = fromMap[vertex], outEdges.count == 2,
              let inEdges = toMap[vertex], inEdges.count == 2 else {
            // If a vertex has more or fewer than 2 incoming or outgoing edges, it should not be optimized
            return patch
        }

        let sourceToLeft = outEdges[0]
        let sourceToRight = outEdges[1]
        let left = sourceToLeft.to
        let right = sourceToRight.to
        let leftToSource = inEdges.first { $0.isReversed(sourceToLeft) }
        let rightToSource = inEdges.first { $0.isReversed(sourceToRight) }
        guard let leftToSource = leftToSource, let rightToSource = rightToSource else {
            // If the incoming and outgoing edges are not symmetric, a vertex should not be optimized
            return patch
        }

        let leftToRightPoints = left.point + leftToSource.intermediatePoints + vertex.point + sourceToRight.intermediatePoints + right.point
        let rightToLeftPoints = right.point + rightToSource.intermediatePoints + vertex.point + sourceToLeft.intermediatePoints + left.point
        let leftToRight = Edge(points: leftToRightPoints, from: left, to: right)
        let rightToLeft = Edge(points: rightToLeftPoints, from: right, to: left)

        removeVertex(vertex)
        appendEdge(leftToRight)
        appendEdge(rightToLeft)

        patch.removedVertices.append(vertex)
        patch.addedEdges.append(leftToRight)
        patch.addedEdges.append(rightToLeft)
        return patch
    }

    func nearest(to vertex: Vertex) -> Set<Vertex> {
        let to = fromMap[vertex]?.map { $0.to } ?? []
        let from = toMap[vertex]?.map { $0.from} ?? []
        return Set(to).union(from)
    }

    func availableFrom(_ vertex: Vertex) -> Set<Vertex> {
        var result: Set<Vertex> = []
        var pointers: Set<Vertex> = [vertex]

        while !pointers.isEmpty {
            result.formUnion(pointers)
            pointers = pointers.reduce(into: Set<Vertex>()) { acc, pointer in
                let new = nearest(to: pointer).filter { !result.contains($0) }
                acc.formUnion(new)
            }
        }

        return result
    }

    func area(from vertex: Vertex) -> Area {
        let area = Area()
        var pointers: Set<Vertex> = [vertex]
        var handled: Set<Vertex> = []

        while !pointers.isEmpty {
            var nextPointers: Set<Vertex> = []
            for vertex in pointers {
                area.graph.appendVertex(vertex)

                for edge in fromMap[vertex, default: []] {
                    if isBidirectional(edge) {
                        area.graph.appendEdge(edge)
                        nextPointers.insert(edge.to)
                    } else {
                        area.outgoing.append(edge)
                    }
                }

                for edge in toMap[vertex, default: []] {
                    if isBidirectional(edge) {
                        area.graph.appendEdge(edge)
                        nextPointers.insert(edge.from)
                    } else {
                        area.income.append(edge)
                    }
                }

                handled.insert(vertex)
            }

            pointers = nextPointers.filter { !handled.contains($0) }
        }

        return area
    }

    func isolatedAreas() -> [Area] {
        var unhandled = Set(vertices)
        var areas: [Area] = []

        while !unhandled.isEmpty {
            guard let vertex = unhandled.first else { continue }
            let area = area(from: vertex)
            areas.append(area)
            unhandled.subtract(area.graph.vertices)
        }

        return areas
    }

    func appendEdge(points: [T.Point]) {
        guard let from = points.first, let to = points.last, from != to else { return }
        let fromVertex = vertices.first { $0.point == from } ?? Vertex(point: from)
        let toVertex = vertices.first { $0.point == to } ?? Vertex(point: to)

        let edge = Edge(points: points, from: fromVertex, to: toVertex)
        appendEdge(edge)
    }

    func appendEdge(_ edge: Edge) {
        edges.insert(edge)
        appendVertex(edge.from)
        appendVertex(edge.to)
        fromMap.append(key: edge.from, arrayValue: edge)
        toMap.append(key: edge.to, arrayValue: edge)
    }

    func removeEdge(_ edge: Edge) {
        edges.remove(edge)
        fromMap.remove(key: edge.from, arrayValue: edge)
        toMap.remove(key: edge.to, arrayValue: edge)
        removeIfUnused(edge.from)
        removeIfUnused(edge.to)
    }

    func appendVertex(_ vertex: Vertex) {
        vertices.insert(vertex)
    }

    func removeVertex(_ vertex: Vertex) {
        vertices.remove(vertex)
        fromMap[vertex]?.forEach { removeEdge($0) }
        toMap[vertex]?.forEach { removeEdge($0) }
        fromMap[vertex] = nil
        toMap[vertex] = nil
    }

    func embedVertex(atPoint point: T.Point) -> PathsGraphPatch<T> {
        var patch = PathsGraphPatch<T>()

        if let exist = vertices.first(where: { $0.point == point }) {
            patch.addedVertices.append(exist)
            return patch
        }

        let newVertex = Vertex(point: point)
        appendVertex(newVertex)
        patch.addedVertices.append(newVertex)

        edges
            .filter { $0.intermediatePoints.contains(point) }
            .forEach {
                removeEdge($0)
                patch.removedEdges.append($0)

                let subPoints = $0.points.split(separator: point)
                let leftPoints = Array(subPoints[0]) + point
                let rightPoints = point + Array(subPoints[1])
                let left = Edge(points: leftPoints, from: $0.from, to: newVertex)
                let right = Edge(points: rightPoints, from: newVertex, to: $0.to)

                appendEdge(left)
                appendEdge(right)
                patch.addedEdges.append(left)
                patch.addedEdges.append(right)
        }

        return patch
    }

    func merge(_ graph: PathsGraph<T>) {
        vertices.formUnion(graph.vertices)
        edges.formUnion(graph.edges)

        fromMap.merge(graph.fromMap) { current, new in
            return current + new
        }

        toMap.merge(graph.toMap) { current, new in
            return current + new
        }
    }

    private func isBidirectional(_ edge: Edge) -> Bool {
        existedReverse(edge) != nil
    }

    private func existedReverse(_ edge: Edge) -> Edge? {
        fromMap[edge.to, default: []].first { $0.isReversed(edge) }
    }

    private func removeIfUnused(_ vertex: Vertex) {
        let emptyFrom = fromMap[vertex]?.isEmpty ?? true
        let emptyTo = toMap[vertex]?.isEmpty ?? true
        if emptyTo && emptyFrom { removeVertex(vertex) }
    }
}
