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
    var superpositions: [[SquareSuperposition]] = []

    required init(superpositionsProvider: SuperpositionsProvider<SquareTopology>) {
        super.init(superpositionsProvider: superpositionsProvider)
        for x in 0..<size.0 {
            var superColumn: [SquareSuperposition] = []

            for y in 0..<size.1 {
                let point = SquarePoint(x: x, y: y)
                let elementsSuperposition = superpositionsProvider.instantiate()
                let superposition = SquareSuperposition(point: point, elementsSuperpositions: elementsSuperposition)
                superColumn.append(superposition)
            }

            superpositions.append(superColumn)
        }
    }

    override func allPoints() -> [SquarePoint] {
        (0..<size.0).flatMap { x in
            (0..<size.1).map { y in
                SquarePoint(x: x, y: y)
            }
        }
    }

    override func allSuperpositions() -> [NodeSuperposition<SquareTopology>] {
        superpositions.flatMap { $0 }
    }

    override func contains(_ point: SquarePoint) -> Bool {
        (0..<size.0).contains(point.x) && (0..<size.0).contains(point.y)
    }

    override func element(at point: SquarePoint) -> TopologyBasedLabyrinthElement<SquareTopology>? {
        nodes[point]
    }

    override func superpositionAt(_ point: SquarePoint) -> NodeSuperposition<SquareTopology>? {
        superpositions[safe: point.x]?[safe: point.y]
    }
}
