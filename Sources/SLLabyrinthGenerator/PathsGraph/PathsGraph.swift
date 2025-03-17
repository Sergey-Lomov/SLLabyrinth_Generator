//
//  PathsGraph.swift
//  SLLabyrinthGenerator
//
//  Created by serhii.lomov on 09.03.2025.
//
//

final class PathsGraph<T: Topology>: Graph<PathsGraphEdge<T>> {
    typealias Edge = PathsGraphEdge<T>
    typealias Vertex = PathsGraphVertex<T>
    typealias Area = PathsGraphArea<T>
    typealias Path = PathsGraphPath<T>

    @Cached var points: Set<T.Point>

    override init() {
        super.init()
        _points.compute = calculatePoints
    }

    override func invalidateCache() {
        _points.invaliade()
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

    func areaAvailable(from vertex: Vertex) -> Area {
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
                    }
                }

                for edge in toMap[vertex, default: []] {
                    if isBidirectional(edge) {
                        area.graph.appendEdge(edge)
                        nextPointers.insert(edge.from)
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
            let area = areaAvailable(from: vertex)
            areas.append(area)
            unhandled.subtract(area.graph.vertices)
        }

        return areas
    }

    func noDeadendsGraph() -> PathsGraph {
        let result = PathsGraph(graph: self)

        var deadends = result.deadends()
        while deadends.count > 0 {
            deadends.forEach { result.removeVertex($0) }
            deadends = result.deadends()
        }

        return result
    }

    func toAreasGraph() -> AreasGraph<T> {
        let verticesPairs = vertices.map { ($0, Area(vertex: $0)) }
        let areasMap = Dictionary(uniqueKeysWithValues: verticesPairs)

        let edges: [AreasGraphEdge<T>] = edges.compactMap { edge in
            let from = areasMap[edge.from]
            let to = areasMap[edge.to]
            guard let from = from, let to = to else { return nil }
            return AreasGraphEdge(pathsEdge: edge, from: from, to: to)
        }

        return AreasGraph(edges: edges)
    }

    func appendEdge(points: [T.Point]) {
        guard let from = points.first, let to = points.last, from != to else { return }
        let fromVertex = vertices.first { $0.point == from } ?? Vertex(point: from)
        let toVertex = vertices.first { $0.point == to } ?? Vertex(point: to)

        let edge = Edge(points: points, from: fromVertex, to: toVertex)
        appendEdge(edge)
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

    private func calculatePoints() -> Set<T.Point> {
       if edges.isEmpty {
           return Set(vertices.map { $0.point })
       } else {
           return Set(edges.flatMap { $0.points })
       }
    }

    private func isBidirectional(_ edge: Edge) -> Bool {
        existedReverse(edge) != nil
    }

    private func existedReverse(_ edge: Edge) -> Edge? {
        fromMap[edge.to, default: []].first { $0.isReversed(edge) }
    }

    private func deadends() -> Set<Vertex> {
        vertices.filter {
            let incomes = toMap[$0, default: []]
            let outgoings = fromMap[$0, default: []]

            // Only vertices with one incoming and one outgoing edge should be treated as dead ends.
            if incomes.count != 1 || outgoings.count != 1 { return false }
            guard let income = incomes.first, let outgoing = outgoings.first else {
                return false
            }

            // If a vertex is self-cycled, it should not be treated as a dead end.
            if income.from == income.to || outgoing.from == outgoing.to { return false }

            // If a vertex's incoming edge is not symmetrical to its outgoing edge, it should not be treated as a dead end.
            return income.isReversed(outgoing)
        }
    }
}
