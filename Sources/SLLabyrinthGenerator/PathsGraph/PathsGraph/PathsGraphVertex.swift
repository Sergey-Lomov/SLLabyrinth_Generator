//
//  PathsGraphVertex.swift
//  SLLabyrinthGenerator
//
//  Created by serhii.lomov on 09.03.2025.
//

import Foundation

struct PathsGraphVertex<T: Topology>: GraphVertex, Equatable {
    var point: T.Point
}
