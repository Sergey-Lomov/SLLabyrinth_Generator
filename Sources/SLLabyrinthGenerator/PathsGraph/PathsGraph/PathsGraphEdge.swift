//
//  PathsGraphEdge.swift
//  SLLabyrinthGenerator
//
//  Created by serhii.lomov on 09.03.2025.
//

import Foundation

public enum PathsGraphEdgeType {
    case common
    case teleport
}

struct PathsGraphEdge<T: Topology>: GraphEdge {
    typealias Vertex = PathsGraphVertex<T>

    var id = UUID().uuidString

    let type: PathsGraphEdgeType
    private(set) var points: [T.Point]
    private(set) var from: Vertex
    private(set) var to: Vertex

    @Cached var intermediatePoints: [T.Point]
    @Cached var length: Float

    init(type: PathsGraphEdgeType, points: [T.Point], from: Vertex, to: Vertex) {
        self.type = type
        self.points = points
        self.from = from
        self.to = to

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
        let reversed = Self(type: type, points: points.reversed(), from: to, to: from)
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
