//
//  CornerPath.swift
//  SLLabyrinthGenerator
//
//  Created by serhii.lomov on 05.03.2025.
//

import Foundation

/// A labyrinth element with two entrances on non-opposite sides.
final class CornerPath<T: Topology>: PassagesInstantiableElement<T> {}

final class CornerPathSuperposition<T: Topology>: PassagesInstantiableSuperposition<T, CornerPath<T>>, CategorizedSuperposition {
    static var category: String { "corner_path" }

    override func filterInitialPassages(_ variant: [T.Edge]) -> Bool {
        guard variant.count == 2 else { return false }
        return variant[0].opposite() != variant[1]
    }
}
