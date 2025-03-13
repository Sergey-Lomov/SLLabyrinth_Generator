//
//  NodeSuperposition.swift
//  SLLabyrinthGenerator
//
//  Created by serhii.lomov on 05.03.2025.
//

public protocol NodeSuperposition {
    associatedtype Point: TopologyPoint
    associatedtype Nested: ElementSuperposition

    var point: Point { get }
    var elementsSuperpositions: [Nested] { get }
    var entropy: Int { get }

    init(point: Point, elementsSuperpositions: [Nested])
    func applyRestriction(_ restriction: AppliedRestriction)
    func applyRestriction(_ restriction: any SuperpositionRestriction, provider: String)
    func waveFunctionCollapse() -> Nested.Element?

    func resetRestrictions() -> [AppliedRestriction]
    func resetRestrictions(by provider: String)
}

extension NodeSuperposition {
    func applyRestriction(_ applied: AppliedRestriction) {
        applyRestriction(applied.restriction, provider: applied.provider)
    }
}

/// Node superposition
final class TopologyBasedNodeSuperposition<T: Topology>: NodeSuperposition {
    typealias Point = T.Point
    typealias Nested = TopologyBasedElementSuperposition<T>

    var point: Point
    var elementsSuperpositions: [Nested] = []
    private var restrictions: [AppliedRestriction] = []

    @Cached var entropy: Int

    init(point: Point, elementsSuperpositions: [Nested]) {
        self.point = point
        self.elementsSuperpositions = elementsSuperpositions
        _entropy.compute = caclulateEntropy
    }

    func applyRestriction(_ restriction: any SuperpositionRestriction, provider: String) {
        let applied = AppliedRestriction(restriction: restriction, provider: provider)
        restrictions.append(applied)

        switch restriction {
        case let restriction as T.Field.Element.Restriction:
            applyElementRestriction(restriction)
        case let restriction as NodeRestriction:
            applyNodeRestriction(restriction)
        default:
            break
        }

        _entropy.invaliade()
    }

    func waveFunctionCollapse() -> T.Field.Element? {
        let available = elementsSuperpositions.filter { $0.entropy > 0 }
        return available.randomElement()?.waveFunctionCollapse()
    }

    func resetRestrictions() -> [AppliedRestriction] {
        defer {
            restrictions = []
            _entropy.invaliade()
        }

        elementsSuperpositions.forEach { $0.resetRestrictions() }
        return restrictions
    }

    func resetRestrictions(by provider: String) {
        resetRestrictions()
            .filter { $0.provider != provider }
            .forEach { applyRestriction($0) }
    }

    private func caclulateEntropy() -> Int {
        elementsSuperpositions
            .map { $0.entropy }
            .reduce(0, +)
    }

    private func applyNodeRestriction(_ restriction: NodeRestriction) {
        elementsSuperpositions = elementsSuperpositions.filter {
            restriction.validateElement($0)
        }
    }

    private func applyElementRestriction(_ restriction: Nested.Element.Restriction) {
        elementsSuperpositions.forEach {
            $0.applyRestriction(restriction)
        }
    }
}
