//
//  Bridge.swift
//  SLLabyrinthIOS
//
//  Created by serhii.lomov on 06.04.2025.
//

import Foundation

final class Bridge<T: Topology>: TopologyBasedLabyrinthElement<T> {
    typealias Edge = T.Edge

    let paths: [[Edge]]

    init(paths: [[Edge]]) {
        self.paths = paths
    }

    override func connected(_ point: Point) -> [ElementConnectionsGroup<Point>] {
        paths.map { path in
            let typeTitle = "bridge_\(path[0])_\(path[1])"
            let type = PathsVertexType(title: typeTitle, compactizable: true)

            let connections = path.map { edge in
                let next = T.nextPoint(point: point, edge: edge)
                return ElementsConnection(point: next, type: .passage)
            }

            let validator: ([Point]) -> Bool = { points in
                Self.vertexEdgeValidator(points: points, vertexPoint: point, path: path)
            }

            return ElementConnectionsGroup(
                vertexType: type,
                connections: connections,
                validator: validator
            )
        }
    }

    override func outcomeRestrictions<F: TopologyField>(point: Point, field: F) -> OutcomeRestrictions {
        var restrictions = super.outcomeRestrictions(point: point, field: field)

        let passages = paths.flatMap { $0 }
        T.Edge.allCases.forEach {
            let isPassage = passages.contains($0)
            let nextEdge = T.adaptToNextPoint($0)
            let restriction: Restriction = isPassage ? .passage(edge: nextEdge) : .wall(edge: nextEdge)
            let next = T.nextPoint(point: point, edge: $0)
            restrictions.append(key: next, arrayValue: restriction)
        }

        return restrictions
    }

    private static func vertexEdgeValidator(points: [Point], vertexPoint: Point, path: [Edge]) -> Bool {
        var nearest: Point?
        if points.first == vertexPoint {
            nearest = points[safe: 1]
        } else if points.last == vertexPoint {
            nearest = points[safe: points.count - 2]
        }

        guard let nearest = nearest else { return false }
        guard let edge = T.edge(from: vertexPoint, to: nearest) else { return false }
        return path.contains(edge)
    }
}
