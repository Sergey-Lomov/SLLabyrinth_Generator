//
//  PathsGraphEdge.swift
//  SLLabyrinthGenerator
//
//  Created by serhii.lomov on 09.03.2025.
//

import Foundation

struct PathsGraphEdge<T: Topology>: GraphEdge {
    typealias Vertex = PathsGraphVertex<T>

    var id = UUID().uuidString

    private(set) var points: [T.Point]
    private(set) var from: Vertex
    private(set) var to: Vertex

    @Cached var intermediatePoints: [T.Point]

    init(points: [T.Point], from: Vertex, to: Vertex) {
        self.points = points
        self.from = from
        self.to = to

        _intermediatePoints.compute = {
            points.filter { $0 != points.first && $0 != points.last }
        }
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    func isReversed(_ edge: PathsGraphEdge<T>) -> Bool {
        points == Array(edge.points.reversed())
    }

    func reversed() -> Self {
        Self(points: points.reversed(), from: to, to: from)
    }

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.points == rhs.points
    }
}
