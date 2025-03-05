//
//  File.swift
//  SLLabirintGenerator
//
//  Created by serhii.lomov on 05.03.2025.
//

import Foundation

protocol LabirintElement {
    /// Topology associated with the element. Typically, the possible values for all or at least some properties of the element depend on the topology.
    associatedtype Topology: SLLabirintGenerator.Topology
}
