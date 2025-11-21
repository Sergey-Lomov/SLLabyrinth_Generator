//
//  ElementSuperposition.swift
//  SLLabyrinthGenerator
//
//  Created by serhii.lomov on 05.03.2025.
//

import Foundation

/// This protocol describes the element superposition. This means an element with partially undetermined property values. For example, "deadend with an entrance from the north or from the west".
public protocol ElementSuperposition: IdHashable {
    associatedtype Point: TopologyPoint
    associatedtype Edge: TopologyEdge
    associatedtype Field: TopologyField
    associatedtype Element: LabyrinthElement

    init()

    /// Entropy describes the variations in possible superposition resolutions.
    /// Typically, entropy decreases when restrictions are applied.
    /// An entropy of 1 indicates that only one resolution is possible, making the superposition logically equivalent to the collapsed element type.
    /// An entropy of 0 means that the superposition cannot be resolved at all. This can occur when the element superposition is part of a node superposition.
    /// However, an entropy greater than 1 does not necessarily equal the number of possible resolutions. Only absoluteEntropy guarantees this correspondence.
    var entropy: Int { get }

    /// Absolute entropy is the total number of all possible superposition resolutions.
    /// In most cases, it is equivalent to entropy.
    func absoluteEntropy(point: Point, field: Field) -> Int

    /// This method applies restrictions to the superposition. This may decrease the possible values for superposition properties and, if so, decrease the superposition entropy.
    /// For example, we have a square topology, and the superposition is "deadend with entrance from any edge" (entropy 4). The nearest south node superposition collapses and produces the restriction "wall at north."
    /// For this node, it means a wall at the south, so now we have the superposition "deadend with entrance from any edge except south" (entropy 3).
    func applyRestriction(_ restriction: any ElementRestriction, at point: Point) -> Bool

    /// This method should result in a superposition configuration that cannot produce the specified constraint when collapsing.
    /// Returns true if the superposition was reconfigured; otherwise returns false.
    func preventRestriction(_ restriction: any ElementRestriction)

    /// This method reverses all applied restrictions and restores the superposition's initial state.
    func resetRestrictions()

    /// Collapse means superposition resolution. Thus, the superposition becomes a fully determined element.
    /// For example, the superposition "deadend with entrance from south or west" may collapse to the element "deadend with entrance from south."
    /// - Returns: A new element, or nil if element creation fails (due to applied restrictions)
    func waveFunctionCollapse(point: Point, field: Field) -> Element?

    func copy() -> Self
}

class TopologyBasedElementSuperposition<T: Topology>: ElementSuperposition {    
    typealias Point = T.Point
    typealias Edge = T.Edge
    typealias Field = T.Field

    var id = UIDProvider.next()
    var entropy: Int { 0 }

    required init() {}

    func absoluteEntropy(point: T.Point, field: T.Field) -> Int {
        return entropy
    }

    func applyRestriction(_ restriction: any ElementRestriction, at point: Point) -> Bool {
        switch restriction {
        case let restriction as PassagesElementRestriction<T>:
            return applyPassagesRestriction(restriction, at: point)
        case let restriction as ConnectionPreventRestriction<T>:
            return applyConnectionRestriction(restriction, at: point)
        default:
            return applySpecificRestriction(restriction, at: point)
        }
    }

    internal func applyPassagesRestriction(_ restriction: PassagesElementRestriction<T>, at point: Point) -> Bool { false }
    internal func applyConnectionRestriction(_ restriction: ConnectionPreventRestriction<T>, at point: Point) -> Bool { false }
    internal func applySpecificRestriction(_ restriction: any ElementRestriction, at point: Point) -> Bool { false }

    func preventRestriction(_ restriction: any ElementRestriction) {
        switch restriction {
        case let restriction as PassagesElementRestriction<T>:
            preventPassagesRestriction(restriction)
        default:
            preventSpecificRestriction(restriction)
        }
    }

    internal func preventPassagesRestriction(_ restriction: PassagesElementRestriction<T>) {}
    internal func preventSpecificRestriction(_ restriction: any ElementRestriction) {}

    func resetRestrictions() {}
    func waveFunctionCollapse(point: Point, field: Field) -> T.Field.Element? { nil }
    func copy() -> Self { fatalError("Should be overrided in derived class") }
}
