//
//  FieldAnalyzer.swift
//  SLLabyrinthGenerator
//
//  Created by serhii.lomov on 08.03.2025.
//

import Foundation

final class FieldAnalyzer {
    static func pathsGraph<T: Topology>(_ field: Field<T>) -> PathsGraph<T> {
        var unhandled = field.allPoints()
        var graph = PathsGraph<T>()

        while !unhandled.isEmpty {
            guard let point = unhandled.first else { continue }
            unhandled.removeFirst()
            guard let element = field.nodeAt(point)?.element, element.isVisitable else {
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

    static func path<T: Topology>(from: T.Point, to: T.Point, field: Field<T>) -> [T.Point]? {
        paths(from: from, to: to, field: field, countLimit: 1).first
    }

    static func paths<T: Topology>(
        from: T.Point,
        to: T.Point,
        field: Field<T>,
        lengthLimit: Int = Int.max,
        countLimit: Int = Int.max
    ) -> [[T.Point]] {
        var searchPaths: [[T.Point]] = [[from]]
        var resultPaths: [[T.Point]] = [[]]

        while !searchPaths.isEmpty && resultPaths.count < countLimit {
            searchPaths = searchPaths.flatMap { path in
                guard let head = path.last else { return Array<Array<T.Point>>() }
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
