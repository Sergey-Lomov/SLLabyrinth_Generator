//
//  StraightPath.swift
//  SLLabyrinthGenerator
//
//  Created by serhii.lomov on 05.03.2025.
//

import Foundation

/// A labyrinth element with two entrances on opposite sides.
final class StraightPath<T: Topology>: PassagesInstantiableElement<T> { }

final class StraightPathSuperposition<T: Topology>: PassagesInstantiableSuperposition<T, StraightPath<T>>, CategorizedSuperposition {

    static var category: String { "straight_path" }

    override func filterInitialPassages(_ variant: [T.Edge]) -> Bool {
        guard variant.count == 2 else { return false }
        return variant[0].opposite() == variant[1]
    }
}
