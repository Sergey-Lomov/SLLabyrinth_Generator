//
//  MinLengthCycledAreasStrategy.swift
//  SLLabyrinthIOS
//
//  Created by serhii.lomov on 18.03.2025.
//

import Foundation

final class MinLengthCycledAreasStrategy<T: Topology>: CycledAreasStrategy<T> {
    private let providerPrefix = "cycles_resolving_"

    let minLength: Float

    init(minLength: Float) {
        self.minLength = minLength
    }

    override func handle(area: PathsGraphArea<T>, generator: Generator) -> Bool {
        var failed: Set<PathsGraphPath<T>> = []
        var unhandled = area.graph.vertices

        while !unhandled.isEmpty {
            while let cycle = cycle(area: area, vertex: unhandled.first, failed: failed) {
                let success = handleUnapprovedCycle(cycle, area: area, generator: generator)
                if !success {
                    failed.insert(cycle)
                }
            }

            unhandled.removeFirst()
        }

        return true
    }

    private func cycle(area: PathsGraphArea<T>, vertex: PathsGraphVertex<T>?, failed: Set<PathsGraphPath<T>>) -> PathsGraphPath<T>? {
        guard let vertex = vertex else { return nil }

        return area.graph.firstPath(
            from: [vertex],
            successValidator: { $0.from == $0.to },
            earlyStopValidator: { $0.lenght >= minLength || failed.contains($0) }
        )
    }

    private func handleUnapprovedCycle(
        _ path: PathsGraphPath<T>,
        area: PathsGraphArea<T>,
        generator: LabyrinthGenerator<T>
    ) -> Bool {
        let bidirectional = area.graph.isBidirectional(path)
        let provider = providerPrefix + area.id

        for edge in path.edges {
            guard edge.points.count >= 2 else { continue }

            if !bidirectional {
                let anotherWay1 = area.graph.anyPath(from: edge.to, to: edge.from, ignores: [edge])
                let anotherWay2 = area.graph.anyPath(from: edge.from, to: edge.to, ignores: [edge])
                guard anotherWay1 != nil && anotherWay2 != nil else {
                    continue
                }
            }

            let strategy = generator.configuration.edgeCuttingStrategy(type: edge.type)
            let success = strategy.tryToCut(edge, generator: generator, provider: provider)
            
            if success {
                area.graph.removeAndCompactize(edge)
                if edge.type.bidirectional {
                    if let reversed = area.graph.existedReverse(edge) {
                        area.graph.removeAndCompactize(reversed)
                    }
                }
                return true
            }
        }

        return false
    }
}
