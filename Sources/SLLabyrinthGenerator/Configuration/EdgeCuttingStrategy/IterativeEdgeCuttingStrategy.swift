//
//  IterativeEdgeCuttingStrategy.swift
//  SLLabyrinthIOS
//
//  Created by serhii.lomov on 03.04.2025.
//

final class IterativeEdgeCuttingStrategy<T: Topology>: EdgeCuttingStrategy<T> {
    override func tryToCut(_ edge: Edge, generator: Generator, provider: String) -> Bool {
        for i in (1..<edge.points.count).reversed() {
            let point1 = edge.points[i]
            let point2 = edge.points[i-1]
            let success = tryCut(point1: point1, point2: point2, provider: provider, generator: generator)
            if success { return true }
        }

        return false
    }

    private func tryCut(point1: T.Point, point2: T.Point, provider: String, generator: Generator) -> Bool {
        guard let edge1 = T.edge(from: point1, to: point2) else { return false }
        let edge2 = T.adaptToNextPoint(edge1)

        let restriction1 = ConnectionRestriction(target: point2)
        let restriction2 = ConnectionRestriction(target: point1)

        let restrictions = [
            point1 : [restriction1],
            point2 : [restriction2]
        ]

        let result = generator.regenerate(
            points: [point1, point2],
            restrictions: restrictions,
            restrictionsProvider: provider
        )

        return result.isSuccess
    }
}
