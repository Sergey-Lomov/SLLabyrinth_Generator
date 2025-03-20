//
//  Graph.swift
//  SLLabyrinthIOS
//
//  Created by serhii.lomov on 15.03.2025.
//

import Foundation

protocol GraphVertex: Hashable {}

protocol GraphEdge: IdHashable {
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
    private(set) var fromMap: Dictionary<Vertex, [Edge]> = [:]
    private(set) var toMap: Dictionary<Vertex, [Edge]> = [:]

    convenience init(graph: Graph<Edge>) {
        self.init()

        self.vertices = graph.vertices
        self.edges = graph.edges
        self.fromMap = graph.fromMap
        self.toMap = graph.toMap
    }

    required convenience init(edges: [Edge]) {
        self.init()
        edges.forEach { appendEdge($0) }
    }

    internal func invalidateCache() {}

    func appendEdge(_ edge: Edge) {
        guard !edges.contains(edge) else { return }

        edges.insert(edge)
        appendVertex(edge.from)
        appendVertex(edge.to)
        fromMap.append(key: edge.from, arrayValue: edge)
        toMap.append(key: edge.to, arrayValue: edge)
        invalidateCache()
    }

    func removeEdge(_ edge: Edge) {
        edges.remove(edge)
        fromMap.remove(key: edge.from, arrayValue: edge)
        toMap.remove(key: edge.to, arrayValue: edge)
        removeIfUnused(edge.from)
        removeIfUnused(edge.to)
        invalidateCache()
    }

    func appendVertex(_ vertex: Vertex) {
        guard !vertices.contains((vertex)) else { return }
        vertices.insert(vertex)
        invalidateCache()
    }

    func removeVertex(_ vertex: Vertex) {
        vertices.remove(vertex)
        fromMap[vertex]?.forEach { removeEdge($0) }
        toMap[vertex]?.forEach { removeEdge($0) }
        fromMap[vertex] = nil
        toMap[vertex] = nil
        invalidateCache()
    }

    func edges(from vertex: Vertex) -> [Edge] {
        fromMap[vertex, default: []]
    }

    func edges(to vertex: Vertex) -> [Edge] {
        toMap[vertex, default: []]
    }

    func edges(of vertex: Vertex) -> [Edge] {
        edges(from: vertex) + edges(to: vertex)
    }

    func merge(_ graph: Graph<Edge>) {
        vertices.formUnion(graph.vertices)
        edges.formUnion(graph.edges)

        fromMap.merge(graph.fromMap) { current, new in
            return current + new
        }

        toMap.merge(graph.toMap) { current, new in
            return current + new
        }
    }

    func firstPath<C: Collection, P: Path> (
        from vertices: C,
        successValidator: (P) -> Bool,
        earlyStopValidator: (P) -> Bool = { _ in false },
        forbidReversed: Bool = true
    ) -> P? where C.Element == Vertex {
        var paths = vertices.flatMap { vertex in
            edges(from: vertex).map { edge in
                P(edge: edge)
            }
        }

        while !paths.isEmpty {
            let success = paths.first { successValidator($0) }
            if let success = success { return success }

            paths = paths.flatMap { path in
                guard let to = path.to else { return [P]() }
                return edges(from: to).compactMap { edge in
                    guard let lastEdge = path.edges.last else { return nil }
                    if forbidReversed && lastEdge.isReversed(edge) { return nil }
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
