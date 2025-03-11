//
//  File.swift
//  SLLabyrinthGenerator
//
//  Created by serhii.lomov on 07.03.2025.
//

import Foundation

final class SuperpositionsProvider<T: Topology> {
    private var superpositions: [T.Superposition.Nested.Type] = []

    func reqisterSuperposition(_ superposition: any ElementSuperposition.Type) {
        if let superposition = superposition as? T.Superposition.Nested.Type {
            superpositions.append(superposition)
        }
    }

    func instantiate() -> [T.Superposition.Nested] {
        superpositions.map { $0.init() }
    }
}
