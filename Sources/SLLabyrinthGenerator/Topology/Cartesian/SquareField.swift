//
//  SquareField.swift
//  SLLabyrinthGenerator
//
//  Created by serhii.lomov on 07.03.2025.
//

final class SquareField: Field<SquareTopology> {

    typealias SquareNode = Node<SquareTopology>
    typealias SquareSuperposition = NodeSuperposition<SquareTopology>

    var nodes: Array<Array<SquareNode>> = []
    var superpositions: Array<Array<SquareSuperposition>> = []

    var allSuperpositions: Array<NodeSuperposition<SquareTopology>> {
        superpositions.flatMap { $0 }
    }

    init(superpositionsProvider: SuperpositionsProvider<SquareTopology>) {
        for x in 0...9 {
            var column: Array<SquareNode> = []
            var superColumn: Array<SquareSuperposition> = []

            for y in 0...9 {
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

    override func nodeAt(_ point: SquarePoint) -> Node<SquareTopology>? {
        nodes[safe: point.x]?[safe: point.y]
    }

    override func superpositionAt(_ point: SquarePoint) -> NodeSuperposition<SquareTopology>? {
        superpositions[safe: point.x]?[safe: point.y]
    }
}
