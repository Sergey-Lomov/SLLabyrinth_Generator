//
//  NodeSuperposition.swift
//  SLLabyrinthGenerator
//
//  Created by serhii.lomov on 05.03.2025.
//

/// Node superposition
final class NodeSuperposition<T> where T: Topology {
    var point: T.Point
    var elementsSuperpositions: [LabyrinthElementSuperposition<T>] = []

    var entropy: Int {
        return
            elementsSuperpositions
            .map { $0.entropy }
            .reduce(0, +)
    }

    init(point: T.Point, elementsSuperpositions: [LabyrinthElementSuperposition<T>]) {
        self.point = point
        self.elementsSuperpositions = elementsSuperpositions
    }

    func applyRestriction(_ restriction: NodeRestriction) {
        elementsSuperpositions = elementsSuperpositions.filter {
            restriction.validateElement($0)
        }
    }

    func applyRestriction(_ restriction: ElementRestriction<T>) {
        elementsSuperpositions.forEach {
            $0.applyRestriction(restriction)
        }
    }

    func waveFunctionCollapse() -> LabyrinthElement<T>? {
        let available = elementsSuperpositions.filter { $0.entropy > 0 }
        return available.randomElement()?.waveFunctionCollapse()
    }
}

protocol ElementRestrictionApplicable {
    func applyRestriction<T: Topology>(_ restriction: ElementRestriction<T>)
}
