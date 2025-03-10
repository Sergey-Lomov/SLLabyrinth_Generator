//
//  TopologyVisualizer.swift
//  SLLabyrinthIOS
//
//  Created by serhii.lomov on 10.03.2025.
//

import Foundation

protocol TopologyVisualizerProtocol {}

class TopologyVisualizer<T: Topology>: TopologyVisualizerProtocol {
    static func reristerInProvider() {
        TopologyVisualizersProvider.shared.reqister(visualizer: self, topology: T.self)
    }

    func scale(field: Field<T>, width: Float, height: Float) -> Float { 1 }
    func pointPositions(_ point: T.Point) -> (Float, Float) { (0, 0) }

    required init() {}
}
