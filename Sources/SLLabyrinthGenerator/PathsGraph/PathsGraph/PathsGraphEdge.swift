//
//  PathsGraphEdge.swift
//  SLLabyrinthGenerator
//
//  Created by serhii.lomov on 09.03.2025.
//

import Foundation

// Extensionable enum of edge types
final class PathsEdgeType {
    static var passage: String { "passage_edge" }
}

struct PathsGraphEdge<T: Topology>: GraphEdge {
    typealias Vertex = PathsGraphVertex<T>

    var id = UUID().uuidString

    let type: String
    private(set) var points: [T.Point]
    private(set) var from: Vertex
    private(set) var to: Vertex

    @Cached var intermediatePoints: [T.Point]
    @Cached var length: Float

    var isPassage: Bool { type == PathsEdgeType.passage }

    init(points: [T.Point], from: Vertex, to: Vertex, type: String = PathsEdgeType.passage) {
        self.points = points
        self.from = from
        self.to = to
        self.type = type

        _intermediatePoints.compute = {
            points.filter { $0 != points.first && $0 != points.last }
        }

        _length.compute =  {
            var result: Float = 0
            for i in 0..<(points.count - 1) {
                result += T.distance(point1: points[i], point2: points[i+1])
            }
            return result
        }
    }

    func isReversed(_ edge: PathsGraphEdge<T>) -> Bool {
        points == edge.points.reversed() && type == edge.type
    }

    func reversed() -> Self {
        let reversed = Self(points: points.reversed(), from: to, to: from, type: type)
        reversed._length.copyFrom(_length)
        return reversed
    }

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.points == rhs.points && lhs.type == rhs.type
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(points)
        hasher.combine(type)
    }
}
