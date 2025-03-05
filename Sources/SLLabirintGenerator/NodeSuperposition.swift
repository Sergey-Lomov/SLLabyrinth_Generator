//
//  NodeSuperposition.swift
//  SLLabirinthGenerator
//
//  Created by serhii.lomov on 05.03.2025.
//

/// Node superposition
final class NodeSuperposition<T> where T: Topology {
    var point: T.Point
    var eigenvalues: [LabirinthElement<T>] = []

    var entropy: Int {
        return eigenvalues
            .map { $0.entropy }
            .reduce(0, +)
    }

    init(point: T.Point, eigenvalues: [LabirinthElement<T>]) {
        self.point = point
        self.eigenvalues = eigenvalues
    }

    func applyRestriction(_ restriction: NodeRestriction<T>) {
        eigenvalues = eigenvalues.filter {
            restriction.validateElement($0)
        }
    }

    func applyRestriction(_ restriction: ElementRestriction<T>) {
        eigenvalues = eigenvalues.filter {
            $0.verifyRestriction(restriction)
        }
    }

    func waveFunctionCollapse() -> LabirinthElement<T>? {
        guard let target = eigenvalues.randomElement() else { return nil }
        target.preCollapseSetup()
        return target
    }
}
