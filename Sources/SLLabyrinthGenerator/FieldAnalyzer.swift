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
            guard let point = unhandled.last else { continue }
            unhandled.removeLast()
            guard let element = field.element(at: point), element.isVisitable else {
                continue
            }

            element
                .connectedPoints(point)
                .filter { field.contains($0) }
                .forEach {
                    graph.appendEdge(points: [point, $0])
                }
        }

        return graph
    } 

    static func path<F: TopologyField>(from: F.Point, to: F.Point, field: F) -> [F.Point]? {
        paths(from: from, to: to, field: field, countLimit: 1).first
    }

    static func paths<F: TopologyField>(
        from: F.Point,
        to: F.Point,
        field: F,
        lengthLimit: Int = Int.max,
        countLimit: Int = Int.max
    ) -> [[F.Point]] {
        var searchPaths: [[F.Point]] = [[from]]
        var resultPaths: [[F.Point]] = [[]]

        while !searchPaths.isEmpty && resultPaths.count < countLimit {
            searchPaths = searchPaths.flatMap { path in
                guard let head = path.last else { return [[F.Point]]() }
                let connected = field.connectedPoints(head)
                return connected
                    .compactMap { path.contains($0) ? nil : path + [$0] }
                    .filter { $0.count <= lengthLimit }
            }

            let newResults = searchPaths.filter { $0.last == to }
            resultPaths.append(contentsOf: newResults)
        }

        return resultPaths
    }
}
