//
//  NodeSuperposition.swift
//  SLLabirintGenerator
//
//  Created by serhii.lomov on 05.03.2025.
//

/// Node superposition
final class NodeSuperposition<T> where T: Topology {
    var point: T.Point
    var elementsSuperpositions: [any LabirintElementSuperposition] = []

    var entropy: Int {
        return
            elementsSuperpositions
            .map { $0.entropy }
            .reduce(0, +)
    }

    init(
        point: T.Point,
        elementsSuperpositions: [any LabirintElementSuperposition]
    ) {
        self.point = point
        self.elementsSuperpositions = elementsSuperpositions
    }

    func applyRestriction(_ restriction: NodeRestriction) {
        elementsSuperpositions = elementsSuperpositions.filter {
            restriction.validateElement($0)
        }
    }

    func applyRestriction(_ restriction: ElementRestirction<T>) {
        elementsSuperpositions.forEach { element in
            let test = element.waveFunctionCollapse
            if let e1 = element as? (any LabirintElementSuperposition) {
                let test = e1.applyRestriction
            }
        }
    }
}

protocol ElementRestrictionApplicable {
    func applyRestriction<T: Topology>(_ restriction: ElementRestirction<T>)
}
