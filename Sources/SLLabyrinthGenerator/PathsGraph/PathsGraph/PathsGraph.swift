//
//  PathsGraph.swift
//  SLLabyrinthGenerator
//
//  Created by serhii.lomov on 09.03.2025.
//
//

final class PathsGraph<T: Topology>: Graph<PathsGraphEdge<T>> {
    typealias Point = T.Point
    typealias Edge = PathsGraphEdge<T>
    typealias Vertex = PathsGraphVertex<T>
    typealias Area = PathsGraphArea<T>
    typealias Path = PathsGraphPath<T>

    @Cached var points: Set<Point>
    private var pointEdges: Dictionary<Point, Set<Edge>> = [:]
    private var pointVertices: Dictionary<Point, Set<Vertex>> = [:]

    var usePointsIndexing: Bool = false {
        didSet {
            if usePointsIndexing && !oldValue {
                edges.forEach { edge in
                    edge.points.forEach { pointEdges.insert(key: $0, setValue: edge) }
                }
                vertices.forEach { pointVertices.insert(key: $0.point, setValue: $0) }
            }
        }
    }

    override init() {
        super.init()
        _points.compute = { [unowned self] in self.calculatePoints() }
    }

    override func invalidateCache() {
        _points.invaliade()
    }

    func contains(_ point: T.Point) -> Bool {
        points.contains(point)
    }

    func edges(of point: Point) -> Set<Edge> {
        if usePointsIndexing {
            return pointEdges[point, default: []]
        } else {
            return edges.filter { $0.points.contains(point) }
        }
    }

    func vertices(of point: Point) -> Set<Vertex> {
        if usePointsIndexing {
            return pointVertices[point, default: []]
        } else {
            return vertices.filter { $0.point == point }
        }
    }

    override func appendEdge(_ edge: Edge) {
        super.appendEdge(edge)
        if usePointsIndexing {
            edge.points.forEach {
                pointEdges.insert(key: $0, setValue: edge)
            }
        }
    }

    override func appendVertex(_ vertex: Vertex) {
        super.appendVertex(vertex)
        if usePointsIndexing {
            pointVertices.insert(key: vertex.point, setValue: vertex)
        }
    }

    override func removeEdge(_ edge: Edge, removeUnused: Bool = true) {
        super.removeEdge(edge, removeUnused: removeUnused)
        if usePointsIndexing {
            edge.points.forEach { pointEdges.remove(key: $0, setValue: edge) }
        }
    }

    override func removeVertex(_ vertex: Vertex, removeUnused: Bool = true) {
        super.removeVertex(vertex)
        if usePointsIndexing {
            pointVertices.remove(key: vertex.point, setValue: vertex)
        }
    }

    private func firstVertex(of point: Point) -> Vertex? {
        if usePointsIndexing {
            return pointVertices[point, default: []].first
        } else {
            return vertices.first { $0.point == point }
        }
    }

    func removeAndCompactize(_ edge: Edge) {
        removeEdge(edge)
        compactize(vertex: edge.from)
        compactize(vertex: edge.to)
    }

    /// Embeds vertices that have only two edges into a merged edge. For example, the graph V1--E1-->V2--E2-->V3 will be compacted to V1--E3-->V3, where E3 consists of E1's points plus V2's point plus E2's points.
    func compactizePaths() {
        for vertex in Array(vertices) {
            compactize(vertex: vertex)
        }
    }

    @discardableResult
    func compactize(vertex: Vertex) -> PathsGraphPatch<T> {
        var patch = PathsGraphPatch<T>()

        guard let outEdges = fromMap[vertex]?.toArray(), outEdges.count == 2,
              let inEdges = toMap[vertex]?.toArray(), inEdges.count == 2 else {
            // If a vertex has more or fewer than 2 incoming or outgoing edges, it should not be optimized
            return patch
        }

        let sourceToLeft = outEdges[0]
        let sourceToRight = outEdges[1]
        let left = sourceToLeft.to
        let right = sourceToRight.to
        // If both the right and left edges are self-cycled on the current vertex, the vertex should not be optimized.
        guard left != right || left != vertex else { return patch }

        // Only common edges can be merged
        guard sourceToLeft.isPassage && sourceToRight.isPassage else { return patch }

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

    private func availableArea(from vertex: Vertex) -> (Area, Set<Edge>) {
        let area = Area()
        var pointers: Set<Vertex> = [vertex]
        var handled: Set<Vertex> = []
        var oneways: Set<Edge> = []

        while !pointers.isEmpty {
            var nextPointers: Set<Vertex> = []
            for vertex in pointers {
                area.graph.appendVertex(vertex)

                for edge in fromMap[vertex, default: []] {
                    if isBidirectional(edge) {
                        area.graph.appendEdge(edge)
                        nextPointers.insert(edge.to)
                    } else {
                        oneways.insert(edge)
                    }
                }

                for edge in toMap[vertex, default: []] {
                    if isBidirectional(edge) {
                        area.graph.appendEdge(edge)
                        nextPointers.insert(edge.from)
                    } else {
                        oneways.insert(edge)
                    }
                }

                handled.insert(vertex)
            }

            pointers = nextPointers.filter { !handled.contains($0) }
        }

        let outareaEdges = oneways.filter {
            !area.graph.contains($0.from) || !area.graph.contains($0.to)
        }
        return (area, outareaEdges)
    }

    func isolatedAreas() -> AreasGraph<T> {
        var unhandledVertices = Set(vertices)
        var interareasEdges: Set<Edge> = []
        let areas = AreasGraph<T>()

        while !unhandledVertices.isEmpty {
            guard let vertex = unhandledVertices.first else { continue }
            let areaData = availableArea(from: vertex)
            let area = areaData.0
            areas.appendVertex(area)
            unhandledVertices.subtract(area.graph.vertices)
            interareasEdges.formUnion(areaData.1)
        }

        interareasEdges.forEach { edge in
            let fromArea = areas.vertices.first { $0.graph.vertices.contains(edge.from) }
            let toArea = areas.vertices.first { $0.graph.vertices.contains(edge.to) }
            guard let fromArea = fromArea, let toArea = toArea else { return }

            let areasEdge = AreasGraphEdge(pathsEdge: edge, from: fromArea, to: toArea)
            areas.appendEdge(areasEdge)
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
        let areasMap = vertices
            .map { ($0, Area(vertex: $0)) }
            .toDictionary()

        let edges: [AreasGraphEdge<T>] = edges.compactMap { edge in
            let from = areasMap[edge.from]
            let to = areasMap[edge.to]
            guard let from = from, let to = to else { return nil }
            return AreasGraphEdge(pathsEdge: edge, from: from, to: to)
        }

        return AreasGraph(edges: edges)
    }

    @discardableResult
    func appendEdge(points: [T.Point], type: String = PathsEdgeType.passage) -> Edge? {
        guard let from = points.first, let to = points.last, from != to else { return nil }
        let fromVertex = vertices.first { $0.point == from } ?? Vertex(point: from)
        let toVertex = vertices.first { $0.point == to } ?? Vertex(point: to)

        let edge = Edge(points: points, from: fromVertex, to: toVertex, type: type)
        appendEdge(edge)
        return edge
    }

    @discardableResult
    func embedVertex(atPoint point: T.Point) -> PathsGraphPatch<T> {
        var patch = PathsGraphPatch<T>()

        if let exist = vertices.first(where: { $0.point == point }) {
            patch.addedVertices.append(exist)
            return patch
        }

        let newVertex = Vertex(point: point)
        appendVertex(newVertex)
        patch.addedVertices.append(newVertex)

        edges(of: point)
            .filter { $0.from.point != point && $0.to.point != point }
            .forEach {
                removeEdge($0)
                patch.removedEdges.append($0)

                let subPoints = $0.points.split(separator: point)
                let leftPoints = Array(subPoints[0]) + point
                let rightPoints = point + Array(subPoints[1])
                let left = Edge(points: leftPoints, from: $0.from, to: newVertex, type: $0.type)
                let right = Edge(points: rightPoints, from: newVertex, to: $0.to, type: $0.type)

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

    func isBidirectional(_ path: Path) -> Bool {
        path.edges.allSatisfy { isBidirectional($0) }
    }

    func isBidirectional(_ edge: Edge) -> Bool {
        existedReverse(edge) != nil
    }

    func existedReverse(_ edge: Edge) -> Edge? {
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
