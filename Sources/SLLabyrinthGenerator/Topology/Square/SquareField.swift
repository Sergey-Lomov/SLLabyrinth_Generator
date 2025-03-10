//
//  SquareField.swift
//  SLLabyrinthGenerator
//
//  Created by serhii.lomov on 07.03.2025.
//

final class SquareField: TopologyField {
    typealias Point = SquarePoint
    typealias Element = TopologyBasedLabyrinthElement<SquareTopology>
    typealias SquareSuperposition = NodeSuperposition<SquareTopology>

    let size: (Int, Int) = (10, 10)
    var nodes: Dictionary<SquarePoint, TopologyBasedLabyrinthElement<SquareTopology>> = [:]

    func allPoints() -> [SquarePoint] {
        (0..<size.0).flatMap { x in
            (0..<size.1).map { y in
                SquarePoint(x: x, y: y)
            }
        }
    }

    func contains(_ point: SquarePoint) -> Bool {
        (0..<size.0).contains(point.x) && (0..<size.0).contains(point.y)
    }

    func element(at point: TopologyBasedField<SquareTopology>.Point) -> TopologyBasedField<SquareTopology>.Element? {
        nodes[point]
    }

    func setElement(at point: SquarePoint, element: TopologyBasedLabyrinthElement<SquareTopology>?) {
        guard contains(point) else { return }
        nodes[point] = element
    }

    func connectedPoints(_ point: SquarePoint) -> [SquarePoint] {
        let connected = element(at: point)?.connectedPoints(point)
        let nearest = SquareEdge.allCases.map { SquareTopology.nextPoint(point: point, edge: $0) }
        return (connected ?? nearest).filter { contains($0) }
    }
}
