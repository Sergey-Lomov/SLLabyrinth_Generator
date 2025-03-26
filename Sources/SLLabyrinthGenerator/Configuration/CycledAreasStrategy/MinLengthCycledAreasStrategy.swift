//
//  MinLengthCycledAreasStrategy.swift
//  SLLabyrinthIOS
//
//  Created by serhii.lomov on 18.03.2025.
//

import Foundation

final class MinLengthCycledAreasStrategy<T: Topology>: CycledAreasStrategy<T> {
    typealias Restriction = TopologyBasedElementRestriction<T>

    private let providerPrefix = "cycles_resolving_"

    let minLength: Int

    init(minLength: Int) {
        self.minLength = minLength
    }

    override class func postprocessing(generator: Generator) {
        generator.calculatePathsGraph()
    }

    override func handle(area: PathsGraphArea<T>, generator: Generator) -> Bool {
        var failed: Set<PathsGraphPath<T>> = []
        while let cycle: PathsGraphPath<T> = area.graph.firstPath(
            from: area.graph.vertices,
            successValidator: { $0.from == $0.to },
            earlyStopValidator: { $0.lenght >= minLength || failed.contains($0)}
        ) {
            let success = handleUnapprovedCycle(cycle, area: area, generator: generator)
            if !success {
                failed.insert(cycle)
            }
        }

        return true
    }

    private func handleUnapprovedCycle(
        _ path: PathsGraphPath<T>,
        area: PathsGraphArea<T>,
        generator: LabyrinthGenerator<T>
    ) -> Bool {
        let bidirectional = area.graph.isBidirectional(path)

        for edge in path.edges {
            guard edge.points.count >= 2 else { continue }

            if !bidirectional {
                let anotherWay1 = area.graph.anyPath(from: edge.to, to: edge.from, ignores: [edge])
                let anotherWay2 = area.graph.anyPath(from: edge.from, to: edge.to, ignores: [edge])
                guard anotherWay1 != nil && anotherWay2 != nil else {
                    continue
                }
            }

            for i in (1..<edge.points.count).reversed() {
                let point1 = edge.points[i]
                let point2 = edge.points[i-1]
                let success = tryCut(point1: point1, point2: point2, areaId: area.id, generator: generator)

                if success {
                    area.graph.removeAndCompactize(edge)
                    if let reversed = area.graph.existedReverse(edge) {
                        area.graph.removeAndCompactize(reversed)
                    }
                    return true
                }
            }
        }

        return false
    }

    private func tryCut(point1: T.Point, point2: T.Point, areaId: String, generator: LabyrinthGenerator<T>) -> Bool {
        guard let edge1 = T.edge(from: point1, to: point2) else { return false }
        let edge2 = T.adaptToNextPoint(edge1)

        let restriction1 = Restriction.wall(edge: edge1)
        let restriction2 = Restriction.wall(edge: edge2)

        let restrictions = [
            point1 : [restriction1],
            point2 : [restriction2]
        ]
        let provider = providerPrefix + areaId

        let success = generator.regenerate(
            points: [point1, point2],
            restrictions: restrictions,
            restrictionsProvider: provider
        )

        return success
    }
}
