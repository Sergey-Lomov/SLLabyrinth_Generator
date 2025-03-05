//
//  File.swift
//  SLLabirinthGenerator
//
//  Created by serhii.lomov on 05.03.2025.
//

import Foundation

class NodeRestriction<T: Topology> {
    func validateElement<E: LabirinthElement<T>>(_ element:E) -> Bool {
        return true
    }
}
