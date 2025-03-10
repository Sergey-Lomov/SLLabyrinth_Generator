//
//  File.swift
//  SLLabyrinthGenerator
//
//  Created by serhii.lomov on 07.03.2025.
//

import Foundation

final class SuperpositionsProvider<T: Topology> {
    private var superpositions: Array<TopologyBasedElementSuperposition<T>.Type> = []

    func reqisterSuperposition(_ superposition: TopologyBasedElementSuperposition<T>.Type) {
        superpositions.append(superposition)
    }

    func instantiate() -> Array<TopologyBasedElementSuperposition<T>> {
        superpositions.map { $0.init() }
    }
}
