//
//  SizeBasedIsolatedAreasStrategy.swift
//  SLLabyrinthIOS
//
//  Created by serhii.lomov on 22.03.2025.
//

import Foundation

final class SizeBasedIsolatedAreasStrategy<T: Topology>: IsolatedAreasStrategy<T> {
    private struct SubstrategyNode {
        let size: ClosedRange<Float>
        let weight: Float
        let strategy: IsolatedAreasStrategy<T>
    }

    private var nodes: [SubstrategyNode] = []

    func add(from: Float, to: Float, weight: Float, strategy: IsolatedAreasStrategy<T>) {
        nodes.append(
            SubstrategyNode(size: from...to, weight: weight, strategy: strategy)
        )
    }

    override func handle(area: Area, graph: Graph, generator: Generator) -> Bool {
        let size = Float(area.graph.points.count) / Float(generator.field.allPoints().count)
        let available = nodes.filter { $0.size.contains(size) }
        let weigted = available.map { ($0.strategy, $0.weight) }
        guard let strategy = RandomPicker.weigthed(weigted) else { return false }
        return strategy.handle(area: area, graph: graph, generator: generator)
    }

    override func postprocessing(generator: Generator) {
        nodes.forEach { $0.strategy.postprocessing(generator: generator) }
    }
}
