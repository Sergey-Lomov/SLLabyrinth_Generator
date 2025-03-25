//
//  GraphPath.swift
//  SLLabyrinthIOS
//
//  Created by serhii.lomov on 15.03.2025.
//

import Foundation

class GraphPath<Edge: GraphEdge>: Hashable {
    typealias Vertex = Edge.Vertex

    private(set) var edges: [Edge] = []
    private(set) var vertices: [Vertex] = []

    var isEmpty: Bool { edges.isEmpty }
    var from: Vertex? { edges.first?.from }
    var to: Vertex? { edges.last?.to }

    init() {}

    required convenience init(edge: Edge) {
        self.init()
        append(edge)
    }

    required convenience init<C: Collection>(edges: C) where C.Element == Edge {
        self.init()
        edges.forEach { append($0) }
    }

    required convenience init(path: GraphPath<Edge>) {
        self.init()
        self.edges = path.edges
        self.vertices = path.vertices
    }

    func isEqual(_ path: GraphPath<Edge>) -> Bool {
        return edges == path.edges
    }

    func copy(append edge: Edge) -> Self {
        let new = Self(path: self)
        new.append(edge)
        return new
    }

    func append(_ edge: Edge) {
        guard edge.from == self.to || isEmpty else { return }
        if isEmpty { vertices.append(edge.from) }
        vertices.append(edge.to)
        edges.append(edge)
        invalidateCache()
    }

    func contains(_ vertex: Vertex) -> Bool {
        vertices.contains { $0 == vertex }
    }

    func contains(_ edge: Edge) -> Bool {
        edges.contains { $0 == edge }
    }

    func contains(oneOf edges: [Edge]) -> Bool {
        self.edges.contains { edges.contains($0) }
    }

    func subpath(from: Vertex? = nil, to: Vertex? = nil) -> Self? {
        let from = from ?? edges.first?.from
        let to = to ?? edges.last?.to

        guard let start = edges.firstIndex(where: { $0.from == from }),
              let finish = edges.lastIndex(where: { $0.to == to }),
              start <= finish else {
            return nil
        }

        return Self(edges: edges[start...finish])
    }

    func toGraph<G: Graph<Edge>>() -> G {
        return G(edges: edges)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(edges)
    }

    static func == (lhs: GraphPath, rhs: GraphPath) -> Bool {
        return lhs.edges == rhs.edges && lhs.vertices == rhs.vertices
    }

    internal func invalidateCache() {}
}
