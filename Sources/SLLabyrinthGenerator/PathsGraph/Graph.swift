//
//  Graph.swift
//  SLLabyrinthIOS
//
//  Created by serhii.lomov on 15.03.2025.
//

import Foundation

protocol GraphVertex: Hashable {}

protocol GraphEdge: Hashable {
    associatedtype Vertex: GraphVertex

    var from: Vertex { get }
    var to: Vertex { get }

    func isReversed(_ edge: Self) -> Bool
}

class Graph<Edge: GraphEdge> {
    typealias Vertex = Edge.Vertex
    typealias Path = GraphPath<Edge>

    private(set) var edges: Set<Edge> = []
    private(set) var vertices: Set<Vertex> = []
    private(set) var fromMap: Dictionary<Vertex, Set<Edge>> = [:]
    private(set) var toMap: Dictionary<Vertex, Set<Edge>> = [:]

    required convenience init(graph: Graph<Edge>) {
        self.init()

        self.vertices = graph.vertices
        self.edges = graph.edges
        self.fromMap = graph.fromMap
        self.toMap = graph.toMap

        invalidateCache()
    }

    required convenience init(edges: [Edge]) {
        self.init()
        edges.forEach { appendEdge($0) }
    }

    internal func invalidateCache() {}

    func copy() -> Self {
        Self(graph: self)
    }

    func contains(_ vertex: Vertex) -> Bool {
        vertices.contains(vertex)
    }

    func appendEdge(_ edge: Edge) {
        guard !edges.contains(edge) else { return }
        edges.insert(edge)
        appendVertex(edge.from)
        appendVertex(edge.to)
        fromMap.insert(key: edge.from, setValue: edge)
        toMap.insert(key: edge.to, setValue: edge)
        invalidateCache()
    }

    func removeEdge(_ edge: Edge, removeUnused: Bool = true) {
        edges.remove(edge)
        fromMap.remove(key: edge.from, setValue: edge)
        toMap.remove(key: edge.to, setValue: edge)

        if removeUnused {
            removeIfUnused(edge.from)
            removeIfUnused(edge.to)
        }

        
        invalidateCache()
    }

    func appendVertex(_ vertex: Vertex) {
        guard !vertices.contains((vertex)) else { return }
        vertices.insert(vertex)
        invalidateCache()
    }

    func removeVertex(_ vertex: Vertex, removeUnused: Bool = true) {
        vertices.remove(vertex)
        fromMap[vertex]?.forEach { removeEdge($0, removeUnused: removeUnused) }
        toMap[vertex]?.forEach { removeEdge($0, removeUnused: removeUnused) }
        fromMap[vertex] = nil
        toMap[vertex] = nil
        invalidateCache()
    }

    func edges(from vertex: Vertex) -> Set<Edge> {
        fromMap[vertex, default: []]
    }

    func edges(to vertex: Vertex) -> Set<Edge> {
        toMap[vertex, default: []]
    }

    func edges(of vertex: Vertex) -> Set<Edge> {
        edges(from: vertex).union(edges(to: vertex))
    }

    func merge(_ graph: Graph<Edge>) {
        vertices.formUnion(graph.vertices)
        edges.formUnion(graph.edges)

        fromMap.merge(graph.fromMap) { current, new in
            return current.union(new)
        }

        toMap.merge(graph.toMap) { current, new in
            return current.union(new)
        }

        invalidateCache()
    }

    func anyPath(from: Vertex, to: Vertex, ignores: [Edge] = []) -> Path? {
        return firstPath(
            from: [from],
            successValidator: { $0.to == to },
            earlyStopValidator: { $0.contains(oneOf: ignores) },
            forbidGlobalIntersections: true
        )
    }

    func firstPath<C: Collection, P: Path> (
        from vertices: C,
        successValidator: (P) -> Bool,
        earlyStopValidator: (P) -> Bool = { _ in false },
        forbidReversed: Bool = true,
        forbidSelfIntersections: Bool = true,
        forbidGlobalIntersections: Bool = false
    ) -> P? where C.Element == Vertex {
        var visited: Set<Vertex> = []

        var paths = vertices.flatMap { vertex in
            edges(from: vertex).compactMap { edge in
                let path = P(edge: edge)
                return earlyStopValidator(path) ? nil : path
            }
        }

        while !paths.isEmpty {
            // TODO: Remove test code
            if paths.count > 2000 {
                print("Overfloat by paths")
                return nil
            }

            let success = paths.first { successValidator($0) }
            if let success = success { return success }

            paths = paths.flatMap { path in
                guard let to = path.to else { return [P]() }
                return edges(from: to).compactMap { edge in
                    guard let lastEdge = path.edges.last else { return nil }
                    if forbidReversed && lastEdge.isReversed(edge) { return nil }
                    if forbidSelfIntersections && path.contains(edge.to) && edge.to != path.from { return nil }

                    if forbidGlobalIntersections {
                        if visited.contains(edge.to) {
                            return nil
                        } else {
                            visited.insert(edge.to)
                        }
                    }

                    let newPath = path.copy(append: edge)
                    return earlyStopValidator(newPath) ? nil : newPath
                }
            }
        }

        return nil
    }

    private func removeIfUnused(_ vertex: Vertex) {
        let emptyFrom = fromMap[vertex]?.isEmpty ?? true
        let emptyTo = toMap[vertex]?.isEmpty ?? true
        if emptyTo && emptyFrom { removeVertex(vertex) }
    }
}
