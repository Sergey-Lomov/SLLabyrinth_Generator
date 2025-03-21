//
//  PathsGraphPath.swift
//  SLLabyrinthIOS
//
//  Created by serhii.lomov on 13.03.2025.
//

import Foundation

final class PathsGraphPath<T: Topology>: GraphPath<PathsGraphEdge<T>> {

    var points: [T.Point] {
        edges
            .flatMap { $0.points }
            .reduce(into: [T.Point]()) { acc, point in
                if acc.last != point {
                    acc.append(point)
                }
            }
    }

    var lenght: Int {
        let edgesLengths = edges
            .map { $0.points.count - 1 }
            .reduce(0, +)
        return edgesLengths + 1
    }

    func routeString() -> String {
        vertices
            .map { "\($0.point)" }
            .joined(separator: " ")
    }
}
