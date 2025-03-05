//
//  File.swift
//  SLLabirintGenerator
//
//  Created by serhii.lomov on 05.03.2025.
//

import Foundation

/// This protocol describes the element superposition. This means an element with partially undetermined property values. For example, "deadend with an entrance from the north or from the west".
protocol LabirintElementSuperposition: ElementRestrictionApplicable {
    /// Topology associated with the element. Typically, the possible values for all or at least some properties of the element depend on the topology.
    //associatedtype Topology: SLLabirintGenerator.Topology

    /// The type of the element that will be produced after superposition resolution.
    associatedtype Element: LabirintElement where Element.Topology == Topology

    /// Entropy refers to variations in possible superposition resolutions. Typically, entropy decreases when restrictions are applied.
    /// An entropy of 1 means that only one resolution option exists, so the superposition is logically equivalent to the collapsed element type.
    /// An entropy of 0 means that the superposition cannot be resolved at all. This may make sense when the element superposition is part of a node superposition.
    var entropy: Int { get }

    /// This method applies restrictions to the superposition. This may decrease the possible values for superposition properties and, if so, decrease the superposition entropy.
    /// For example, we have a square topology, and the superposition is "deadend with entrance from any edge" (entropy 4). The nearest south node superposition collapses and produces the restriction "wall at north."
    /// For this node, it means a wall at the south, so now we have the superposition "deadend with entrance from any edge except south" (entropy 3).

    // TODO: Fix mistape
    //func applyRestriction(_ restriction: ElementRestirction<Topology>)

    /// Collapse means superposition resolution. Thus, the superposition becomes a fully determined element.
    /// For example, the superposition "deadend with entrance from south or west" may collapse to the element "deadend with entrance from south."
    func waveFunctionCollapse() -> Element
}
