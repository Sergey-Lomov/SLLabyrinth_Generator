//
//  NodeSuperposition.swift
//  SLLabyrinthGenerator
//
//  Created by serhii.lomov on 05.03.2025.
//

import Foundation

public protocol NodeSuperposition: IdHashable {
    associatedtype Point: TopologyPoint
    associatedtype Field: TopologyField
    associatedtype Nested: ElementSuperposition where Nested.Field == Field, Nested.Point == Point

    var point: Point { get }
    var elementsSuperpositions: [Nested] { get }

    /// Entropy reflects the uncertainty of a superposition.
    /// This value is not strictly equal with the total number of possible superposition resolutions.
    var entropy: Int { get }

    /// Absolute entropy is the total number of all possible superposition resolutions.
    /// In most cases, it is equivalent to entropy.
    func absoluteEntropy(point: Point, field: Field) -> Int

    init(point: Point, elementsSuperpositions: [Nested])
    init(superposition: Self)

    func copy() -> Self

    func waveFunctionCollapse(
        weights: ElementsWeightsContainer,
        point: Point,
        field: Field
    ) -> Nested.Element?

    func applyRestriction(_ restriction: AppliedRestriction)
    func applyRestriction(_ restriction: any SuperpositionRestriction, provider: String, onetime: Bool)
    func applyRestrictions(_ restrictions: [any SuperpositionRestriction], provider: String, onetime: Bool)

    /// This method should result in a superposition configuration that cannot produce the specified constraint when collapsing.
    func preventRestriction(_ restriction: SuperpositionRestriction)

    @discardableResult
    func resetRestrictions() -> [AppliedRestriction]
    func resetRestrictions(by provider: String)
    func resetRestrictions(by providers: [String])
}

extension NodeSuperposition {
    func copy() -> Self {
        Self(superposition: self)
    }

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
    typealias Field = T.Field
    typealias Nested = TopologyBasedElementSuperposition<T>

    var id = UIDProvider.next()
    var point: Point
    var elementsSuperpositions: [Nested] = []
    var availableElements: Set<Nested> = []
    private var restrictions: [AppliedRestriction] = []

    // TODO: It seems that entropy used to be cached, but is no longer. We need to identify why the caching mechanism was removed. The calculateEntropy method should be deleted if caching is no longer used. The removal of caching might be related to the introduction of MinEntropyContainer.
    var entropy: Int {
        availableElements
            .map { $0.entropy }
            .reduce(0, +)
    }

    init(point: Point, elementsSuperpositions: [Nested]) {
        self.point = point
        self.elementsSuperpositions = elementsSuperpositions
        self.availableElements = elementsSuperpositions.toSet()
    }

    init(superposition: TopologyBasedNodeSuperposition<T>) {
        self.point = superposition.point
        self.restrictions = superposition.restrictions
        self.elementsSuperpositions = []
        self.availableElements = []

        superposition.elementsSuperpositions.forEach {
            let copy = $0.copy()
            elementsSuperpositions.append(copy)
            if superposition.availableElements.contains($0) {
                availableElements.insert(copy)
            }
        }
    }

    func absoluteEntropy(point: T.Point, field: T.Field) -> Int {
        availableElements
            .map { $0.absoluteEntropy(point: point, field: field) }
            .reduce(0, +)
    }

    func applyRestriction(_ restriction: any SuperpositionRestriction, provider: String, onetime: Bool = false) {
        let applied = AppliedRestriction(restriction: restriction, provider: provider, isOnetime: onetime)
        restrictions.append(applied)

        // TODO: Implement testing build target or remove testing code
        validateRestrictions()

        switch restriction {
        case let restriction as any ElementRestriction:
            applyElementRestriction(restriction)
        case let restriction as NodeRestriction:
            applyNodeRestriction(restriction)
        default:
            break
        }
    }

    func preventRestriction(_ restriction: any SuperpositionRestriction) {
        switch restriction {
        case let restriction as any ElementRestriction:
            preventElementRestriction(restriction)
        case let restriction as NodeRestriction:
            preventNodeRestriction(restriction)
        default:
            break
        }
    }

    // TODO: Implement testing build target or remove testing code
    private func validateRestrictions() {
        let rests: [PassagesElementRestriction<T>] = restrictions.compactMap {
            guard !$0.isOnetime else { return nil }
            return $0.restriction as? PassagesElementRestriction<T>
        }
        
        for restriction in rests {
            var opposite: PassagesElementRestriction<T>?
            switch restriction {
            case .passage(let edge):
                opposite = .wall(edge: edge)
            case .wall(let edge):
                opposite = .passage(edge: edge)
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

    func waveFunctionCollapse(
        weights: ElementsWeightsContainer,
        point: Point,
        field: Field
    ) -> Field.Element? {
        var available = availableElements.filter { $0.entropy > 0 }
        restrictions = restrictions.filter { !$0.isOnetime }

        while available.count > 0 {
            let weighted = available.map { ($0, weights.weight($0)) }
            guard let superposition = RandomPicker.weigthed(weighted) else { continue }
            if let element = superposition.waveFunctionCollapse(point: point, field: field) {
                return element
            }
            available.remove(superposition)
        }

        return nil
    }

    @discardableResult
    func resetRestrictions() -> [AppliedRestriction] {
        defer {
            restrictions = []
        }

        availableElements = elementsSuperpositions.toSet()
        elementsSuperpositions.forEach { $0.resetRestrictions() }
        return restrictions
    }

    func resetRestrictions(by provider: String) {
        resetRestrictions(by: [provider])
    }

    func resetRestrictions(by providers: [String]) {
        let contains = restrictions.contains { providers.contains($0.provider) }
        guard contains else { return }
        resetRestrictions()
            .filter { !providers.contains($0.provider) }
            .forEach { applyRestriction($0) }
    }

    private func calculateEntropy() -> Int {
        availableElements
            .map { $0.entropy }
            .reduce(0, +)
    }

    private func preventNodeRestriction(_ restriction: NodeRestriction) {
        availableElements = availableElements.filter {
            !restriction.validateElement($0)
        }
    }

    private func applyNodeRestriction(_ restriction: NodeRestriction) {
        availableElements = availableElements.filter {
            restriction.validateElement($0)
        }
    }

    private func preventElementRestriction(_ restriction: any ElementRestriction) {
        elementsSuperpositions.forEach {
            $0.preventRestriction(restriction)
        }
    }

    private func applyElementRestriction(_ restriction: any ElementRestriction) {
        elementsSuperpositions.forEach {
            let handled = $0.applyRestriction(restriction, at: point)
            if !restriction.allowUnhandled && !handled {
                availableElements.remove($0)
            }
        }
    }
}
