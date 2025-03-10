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

    func isReversed(_ edge: PathsGraphEdge) -> Bool {
        points == Array(edge.points.reversed())
    }
}
