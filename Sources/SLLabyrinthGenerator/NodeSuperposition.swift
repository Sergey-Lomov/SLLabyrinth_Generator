//
//  NodeSuperposition.swift
//  SLLabyrinthGenerator
//
//  Created by serhii.lomov on 05.03.2025.
//

protocol NodeSuperposition {
    associatedtype Point: TopologyPoint
    associatedtype Nested: ElementSuperposition

    var point: Point { get }
    var elementsSuperpositions: [Nested] { get }
    var entropy: Int { get }

    init(point: Point, elementsSuperpositions: [Nested])
    func applyRestriction(_ restriction: NodeRestriction)
    func applyRestriction(_ restriction: Nested.Element.Restriction)
    func waveFunctionCollapse() -> Nested.Element?
}

/// Node superposition
final class TopologyBasedNodeSuperposition<T: Topology>: NodeSuperposition {
    typealias Point = T.Point
    typealias Nested = TopologyBasedElementSuperposition<T>

    var point: Point
    var elementsSuperpositions: [Nested] = []

    var entropy: Int {
        return
            elementsSuperpositions
            .map { $0.entropy }
            .reduce(0, +)
    }

    init(point: Point, elementsSuperpositions: [Nested]) {
        self.point = point
        self.elementsSuperpositions = elementsSuperpositions
    }

    func applyRestriction(_ restriction: NodeRestriction) {
        elementsSuperpositions = elementsSuperpositions.filter {
            restriction.validateElement($0)
        }
    }

    func applyRestriction<R: ElementRestriction>(_ restriction: R) where R.Edge == T.Edge {
        elementsSuperpositions.forEach {
            $0.applyRestriction(restriction)
        }
    }

    func waveFunctionCollapse() -> T.Field.Element? {
        let available = elementsSuperpositions.filter { $0.entropy > 0 }
        return available.randomElement()?.waveFunctionCollapse()
    }
}
