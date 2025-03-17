//
//  PathsGraphPath.swift
//  SLLabyrinthIOS
//
//  Created by serhii.lomov on 13.03.2025.
//

import Foundation

final class PathsGraphPath<T: Topology>: GraphPath<PathsGraphEdge<T>> {

    func routeString() -> String {
        vertices
            .map { "\($0.point)" }
            .joined(separator: " ")
    }
}
