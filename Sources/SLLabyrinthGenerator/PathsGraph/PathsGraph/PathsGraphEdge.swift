//
//  PathsGraphEdge.swift
//  SLLabyrinthGenerator
//
//  Created by serhii.lomov on 09.03.2025.
//

import Foundation

// Extensionable enum of edge types
struct PathsEdgeType: Hashable {
    static let passage: PathsEdgeType =
        PathsEdgeType(title: "passage", bidirectional: true)

    var title: String
    var bidirectional: Bool
}

struct PathsGraphEdge<T: Topology>: GraphEdge {
    typealias Vertex = PathsGraphVertex<T>
    typealias Point = T.Point

    // TODO: Powerful optimization point - change UUID() to another id generation way. Or remove IdEqutable at all and switch ro common Equatable/Hashable. UUID() performance issue should be investigated in other places.
    var id = UIDProvider.next()

    let type: PathsEdgeType
    private(set) var points: [Point]
    private(set) var from: Vertex
    private(set) var to: Vertex

    @Cached var intermediatePoints: [Point]
    @Cached var length: Float

    var isPassage: Bool { type == .passage }

    init(points: [Point], from: Vertex, to: Vertex, type: PathsEdgeType = .passage) {
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

    // Splits the edge at the specified point and returns subedges points arrays.
    // If the point is not found on the edge, return full points list of the original edge.
    // If the point appears multiple times on the edge, multiple points sequences will be produced.
    func splitPoints(at separator: Point, includeSeparator: Bool = true) -> [[Point]] {
        var sequences: [[Point]] = []
        var currentSequence: [Point] = []
        for point in points {
            guard point.isEqual(point: separator) else {
                currentSequence.append(point)
                continue
            }

            if includeSeparator {
                currentSequence.append(separator)
            }
            sequences.append(currentSequence)
            currentSequence = includeSeparator ? [separator] : []
        }

        if currentSequence.count > 0 {
            sequences.append(currentSequence)
        }

        return sequences
    }

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.points == rhs.points && lhs.type == rhs.type
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(points)
        hasher.combine(type)
    }
}
