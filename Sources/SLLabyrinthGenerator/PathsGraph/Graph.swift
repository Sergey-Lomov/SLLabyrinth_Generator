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
}

class Graph<Edge: GraphEdge> {
    typealias Vertex = Edge.Vertex

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

    private func removeIfUnused(_ vertex: Vertex) {
        let emptyFrom = fromMap[vertex]?.isEmpty ?? true
        let emptyTo = toMap[vertex]?.isEmpty ?? true
        if emptyTo && emptyFrom { removeVertex(vertex) }
    }
}
