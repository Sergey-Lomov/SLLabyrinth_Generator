//
//  SquareField.swift
//  SLLabyrinthGenerator
//
//  Created by serhii.lomov on 07.03.2025.
//

final class SquareField: Field<SquareTopology> {

    typealias SquareNode = Node<SquareTopology>
    typealias SquareSuperposition = NodeSuperposition<SquareTopology>

    let size: (Int, Int) = (10, 10)
    var nodes: [[SquareNode]] = []
    var superpositions: [[SquareSuperposition]] = []

    init(superpositionsProvider: SuperpositionsProvider<SquareTopology>) {
        for x in 0..<size.0 {
            var column: Array<SquareNode> = []
            var superColumn: [SquareSuperposition] = []

            for y in 0..<size.1 {
                let point = SquarePoint(x: x, y: y)
                let node = SquareNode(point: point)
                let elementsSuperposition = superpositionsProvider.instantiate()
                let superposition = SquareSuperposition(point: point, elementsSuperpositions: elementsSuperposition)
                column.append(node)
                superColumn.append(superposition)
            }

            nodes.append(column)
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

    override func allNodes() -> [Node<SquareTopology>] {
        nodes.flatMap { $0 }
    }

    override func allSuperpositions() -> [NodeSuperposition<SquareTopology>] {
        superpositions.flatMap { $0 }
    }

    override func contains(_ point: SquarePoint) -> Bool {
        (0..<size.0).contains(point.x) && (0..<size.0).contains(point.x)
    }

    override func nodeAt(_ point: SquarePoint) -> Node<SquareTopology>? {
        nodes[safe: point.x]?[safe: point.y]
    }

    override func superpositionAt(_ point: SquarePoint) -> NodeSuperposition<SquareTopology>? {
        superpositions[safe: point.x]?[safe: point.y]
    }
}
