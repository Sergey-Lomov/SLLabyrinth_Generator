//
//  SquareField.swift
//  SLLabyrinthGenerator
//
//  Created by serhii.lomov on 07.03.2025.
//

final class SquareField: Field<SquareTopology> {

    typealias SquareSuperposition = NodeSuperposition<SquareTopology>

    let size: (Int, Int) = (10, 10)
    var nodes: Dictionary<SquarePoint, TopologyBasedLabyrinthElement<SquareTopology>> = [:]

    override func allPoints() -> [SquarePoint] {
        (0..<size.0).flatMap { x in
            (0..<size.1).map { y in
                SquarePoint(x: x, y: y)
            }
        }
    }

    override func contains(_ point: SquarePoint) -> Bool {
        (0..<size.0).contains(point.x) && (0..<size.0).contains(point.y)
    }

    override func element(at point: SquarePoint) -> TopologyBasedLabyrinthElement<SquareTopology>? {
        nodes[point]
    }
}
