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

    /// Entropy refers to variations in possible superposition resolutions. Typically, entropy decreases when restrictions are applied.
    /// An entropy of 1 means that only one resolution option exists, so the superposition is logically equivalent to the collapsed element type.
    /// An entropy of 0 means that the superposition cannot be resolved at all. This may make sense when the element superposition is part of a node superposition.
    var entropy: Int { get }

    /// This method applies restrictions to the superposition. This may decrease the possible values for superposition properties and, if so, decrease the superposition entropy.
    /// For example, we have a square topology, and the superposition is "deadend with entrance from any edge" (entropy 4). The nearest south node superposition collapses and produces the restriction "wall at north."
    /// For this node, it means a wall at the south, so now we have the superposition "deadend with entrance from any edge except south" (entropy 3).
    func applyRestriction(_ restriction: any ElementRestriction, at point: Point) -> Bool

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
    typealias Element = T.Field.Element

    var id = UUID().uuidString
    var entropy: Int { 0 }

    required init() {}

    func applyRestriction(_ restriction: any ElementRestriction, at point: Point) -> Bool {
        switch restriction {
        case let restriction as TopologyBasedElementRestriction<T>:
            return applyEdgesRestriction(restriction, at: point)
        case let restriction as ConnectionPreventRestriction<T>:
            return applyConnectionRestriction(restriction, at: point)
        default:
            return applySpecificRestriction(restriction, at: point)
        }
    }

    func applyEdgesRestriction(_ restriction: TopologyBasedElementRestriction<T>, at point: Point) -> Bool { false }
    func applyConnectionRestriction(_ restriction: ConnectionPreventRestriction<T>, at point: Point) -> Bool { false }
    func applySpecificRestriction(_ restriction: any ElementRestriction, at point: Point) -> Bool { false }

    func resetRestrictions() {}
    func waveFunctionCollapse(point: Point, field: Field) -> T.Field.Element? { return nil }
    func copy() -> Self { fatalError("Should be overrided in derived class") }
}
