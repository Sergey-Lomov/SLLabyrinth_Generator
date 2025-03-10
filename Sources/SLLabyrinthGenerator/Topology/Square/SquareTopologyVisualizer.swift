//
//  SquareTopologyVisualizer.swift
//  SLLabyrinthIOS
//
//  Created by serhii.lomov on 10.03.2025.
//

import Foundation

final class SquareTopologyVisualizer: TopologyVisualizer<SquareTopology> {

    override func scale(field: Field<SquareTopology>, width: Float, height: Float) -> Float {
        guard let field = field as? SquareField else { return 1 }
        let hScale = width / Float(field.size.0)
        let vScale = height / Float(field.size.1)
        return min(hScale, vScale)
    }
    
    override func pointPositions(_ point: SquarePoint) -> (Float, Float) {
        (Float(point.x) + 0.5, Float(point.y) + 0.5)
    }
}
