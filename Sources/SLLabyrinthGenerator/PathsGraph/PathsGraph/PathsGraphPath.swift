//
//  PathsGraphPath.swift
//  SLLabyrinthIOS
//
//  Created by serhii.lomov on 13.03.2025.
//

import Foundation

final class PathsGraphPath<T: Topology>: GraphPath<PathsGraphEdge<T>> {

    @Cached var points: [T.Point]
    @Cached var lenght: Float

    override init() {
        super.init()

        _lenght.compute =  { [unowned self] in
            return self.edges
                .map { $0.length }
                .reduce(0, +)
        }

        _points.compute =  { [unowned self] in
            self.edges
                .flatMap { $0.points }
                .reduce(into: [T.Point]()) { acc, point in
                    if acc.last != point {
                        acc.append(point)
                    }
                }
        }
    }

    func routeString() -> String {
        vertices
            .map { "\($0.point)" }
            .joined(separator: " ")
    }

    override func invalidateCache() {
        _lenght.invaliade()
        _points.invaliade()
    }
}
