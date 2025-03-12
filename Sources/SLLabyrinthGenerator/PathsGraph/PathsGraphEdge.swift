//
//  PathsGraphEdge.swift
//  SLLabyrinthGenerator
//
//  Created by serhii.lomov on 09.03.2025.
//

import Foundation

struct PathsGraphEdge<T: Topology>: Hashable {
    var points: [T.Point]
    var from: PathsGraphVertex<T>
    var to: PathsGraphVertex<T>

    var intermediatePoints: [T.Point] {
        points.filter { $0 != points.first && $0 != points.last }
    }

    func isReversed(_ edge: PathsGraphEdge<T>) -> Bool {
        points == Array(edge.points.reversed()) && edge.to.point == from.point && edge.from.point == to.point
    }

    func reversed() -> Self {
        Self(points: points.reversed(), from: to, to: from)
    }
}
