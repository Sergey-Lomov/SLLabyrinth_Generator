//
//  FieldAnalyzer.swift
//  SLLabyrinthGenerator
//
//  Created by serhii.lomov on 08.03.2025.
//

import Foundation

final class FieldAnalyzer {
    static func pathsGraph<T: Topology>(_ field: T.Field) -> PathsGraph<T> {
        var unhandled = field.allPoints()
        let graph = PathsGraph<T>()

        while !unhandled.isEmpty {
            guard let point = unhandled.randomElement() else { continue }
            unhandled.remove(point)
            guard let element = field.element(at: point), element.isVisitable else {
                continue
            }

            element
                .connected(point)
                .filter { field.contains($0.point) }
                .forEach {
                    let points = [point, $0.point]
                    graph.appendEdge(points: points, type: $0.type)
                }
        }

        return graph
    }
}
