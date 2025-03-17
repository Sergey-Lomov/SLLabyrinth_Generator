//
//  AreasGraphEdge.swift
//  SLLabyrinthIOS
//
//  Created by serhii.lomov on 15.03.2025.
//

import Foundation

struct AreasGraphEdge<T: Topology>: GraphEdge {
    typealias Vertex = PathsGraphArea<T>

    let pathsEdge: PathsGraphEdge<T>
    let from: PathsGraphArea<T>
    let to: PathsGraphArea<T>
}
