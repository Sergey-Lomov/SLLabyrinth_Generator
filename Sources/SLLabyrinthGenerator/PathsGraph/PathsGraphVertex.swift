//
//  PathsGraphVertex.swift
//  SLLabyrinthGenerator
//
//  Created by serhii.lomov on 09.03.2025.
//

import Foundation

struct PathsGraphVertex<T: Topology>: Hashable {
    var point: T.Point
}
