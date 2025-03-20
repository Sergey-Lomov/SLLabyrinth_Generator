//
//  NodeSuperposition.swift
//  SLLabyrinthGenerator
//
//  Created by serhii.lomov on 05.03.2025.
//

import Foundation

public protocol NodeSuperposition: IdHashable {
    associatedtype Point: TopologyPoint
    associatedtype Nested: ElementSuperposition

    var point: Point { get }
    var elementsSuperpositions: [Nested] { get }
    var entropy: Int { get }

    init(point: Point, elementsSuperpositions: [Nested])
    init(superposition: Self)

    func applyRestriction(_ restriction: AppliedRestriction)
    func applyRestriction(_ restriction: any SuperpositionRestriction, provider: String, onetime: Bool)
    func applyRestrictions(_ restrictions: [any SuperpositionRestriction], provider: String, onetime: Bool)
    func waveFunctionCollapse(weights: ElementsWeightsContainer) -> Nested.Element?

    @discardableResult
    func resetRestrictions() -> [AppliedRestriction]
    func resetRestrictions(by provider: String)
    func resetRestrictions(by providers: [String])
}

extension NodeSuperposition {
    func applyRestriction(_ applied: AppliedRestriction) {
        applyRestriction(applied.restriction, provider: applied.provider, onetime: applied.isOnetime)
    }

    func applyRestrictions(_ restrictions: [any SuperpositionRestriction], provider: String, onetime: Bool = false) {
        restrictions.forEach {
            applyRestriction($0, provider: provider, onetime: onetime)
        }
    }
}

/// Node superposition
final class TopologyBasedNodeSuperposition<T: Topology>: NodeSuperposition {
    typealias Point = T.Point
    typealias Nested = TopologyBasedElementSuperposition<T>

    var id = UUID().uuidString
    var point: Point
    var elementsSuperpositions: [Nested] = []
    private var restrictions: [AppliedRestriction] = []

    @Cached var entropy: Int

    init(point: Point, elementsSuperpositions: [Nested]) {
        self.point = point
        self.elementsSuperpositions = elementsSuperpositions
        _entropy.compute = caclulateEntropy
    }

    init(superposition: TopologyBasedNodeSuperposition<T>) {
        self.point = superposition.point
        self.elementsSuperpositions = superposition.elementsSuperpositions.map { $0.copy() }
        self.restrictions = superposition.restrictions
    }

    func applyRestriction(_ restriction: any SuperpositionRestriction, provider: String, onetime: Bool = false) {
        let applied = AppliedRestriction(restriction: restriction, provider: provider, isOnetime: onetime)
        restrictions.append(applied)

        // TODO: Remove testing code
        validateRestrictions()

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

    // TODO: Remove teseting code or refatoring
    private func validateRestrictions() {
        let rests = restrictions.compactMap {
            $0.restriction as? TopologyBasedElementRestriction<T>
        }
        for restriction in rests {
            var opposite: TopologyBasedElementRestriction<T>?
            switch restriction {
            case .passage(let edge):
                opposite = .wall(edge: edge)
            case .wall(let edge):
                opposite = .passage(edge: edge)
            default:
                break
            }

            let same = rests.filter { $0 == restriction }
            if same.count > 1 {
                print("Restrictions contains duplicate")
            }

            let existOpposite = rests.first { $0 == opposite }
            if existOpposite != nil {
                print("Restrictions contains conflict")
            }
        }
    }

    func waveFunctionCollapse(weights: ElementsWeightsContainer) -> T.Field.Element? {
        let available = elementsSuperpositions.filter { $0.entropy > 0 }
        restrictions = restrictions.filter { !$0.isOnetime }
        let weighted = available.map { ($0, weights.weight($0)) }
        let elementSuperposition = RandomPicker.weigthed(weighted)
        return elementSuperposition?.waveFunctionCollapse()
    }

    @discardableResult
    func resetRestrictions() -> [AppliedRestriction] {
        defer {
            restrictions = []
            _entropy.invaliade()
        }

        elementsSuperpositions.forEach { $0.resetRestrictions() }
        return restrictions
    }

    func resetRestrictions(by provider: String) {
        resetRestrictions(by: [provider])
    }

    func resetRestrictions(by providers: [String]) {
        let contains = restrictions.contains(where: { providers.contains($0.provider) })
        guard contains else { return }
        resetRestrictions()
            .filter { !providers.contains($0.provider) }
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
