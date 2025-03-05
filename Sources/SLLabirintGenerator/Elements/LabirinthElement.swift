//
//  File.swift
//  SLLabirinthGenerator
//
//  Created by serhii.lomov on 05.03.2025.
//

import Foundation

/// Abstract base class for Labirinth elements

//  NOTE: A class should be used instead of a protocol due to Swift's restrictions on generic protocols.
class LabirinthElement<T: Topology> {

    /// Entropy describes the range of element variations. Typically, it is 1, but in some rare cases, when the element may be randomly configured during preCollapseSetup, entropy can be higher.
    var entropy: Int { 1 }

    /// This method may be overridden to add restrictions validation
    func verifyRestriction(_ restriction: ElementRestriction<T>) -> Bool {
        return true
    }

    /// This method may be overridden to implement additional configuration before the element is set to the node during wave function collapse.
    func preCollapseSetup() {}
}
