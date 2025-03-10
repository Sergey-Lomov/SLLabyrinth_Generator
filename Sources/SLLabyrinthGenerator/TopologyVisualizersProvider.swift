//
//  TopologyVisualizersProvider.swift
//  SLLabyrinthIOS
//
//  Created by serhii.lomov on 10.03.2025.
//

import Foundation

final class TopologyVisualizersProvider {
    static let shared = TopologyVisualizersProvider()

    private var visualizers: Dictionary<ObjectIdentifier, TopologyVisualizerProtocol.Type> = [:]

    private init() {}

    func reqister(
        visualizer: TopologyVisualizerProtocol.Type,
        topology: any Topology.Type
    ) {
        visualizers[ObjectIdentifier(topology)] = visualizer
    }

    func visuzalizer<T: Topology>(field: Field<T>) -> TopologyVisualizer<T>? {
        let type = visualizers[ObjectIdentifier(T.self)] as? TopologyVisualizer<T>.Type
        return type?.init()
    }
}
